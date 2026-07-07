import Foundation
import Observation

enum ListenStoreError: LocalizedError, Equatable {
    case noteTooLong
    case simulatedSaveFailure
    case cardNotFound

    var errorDescription: String? {
        switch self {
        case .noteTooLong:
            "Keep the private note under 240 characters, then try saving again."
        case .simulatedSaveFailure:
            "The listen card could not be saved. Check the fields and try again."
        case .cardNotFound:
            "This listen card is no longer available. Return to the sound map and choose another card."
        }
    }
}

@Observable
final class ListenStore {
    private struct PersistedState: Codable {
        var cards: [ListenCard]
        var badges: [SoundBadge]
        var favoriteShape: SoundShape?
    }

    private(set) var cards: [ListenCard] = []
    private(set) var badges: [SoundBadge] = []
    var favoriteShape: SoundShape?
    var simulateNextSaveFailure = false
    var lastErrorMessage: String?

    private let storageURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(storageURL: URL? = nil) {
        self.storageURL = storageURL ?? Self.defaultStorageURL()
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        load()
    }

    var activeCards: [ListenCard] {
        cards
            .filter { $0.status == .saved }
            .sorted { $0.heardAt > $1.heardAt }
    }

    var archivedCards: [ListenCard] {
        cards
            .filter { $0.status == .archived }
            .sorted { $0.heardAt > $1.heardAt }
    }

    var hasCards: Bool { !cards.isEmpty }

    func card(with id: UUID) -> ListenCard? {
        cards.first { $0.id == id }
    }

    func save(_ card: ListenCard) throws {
        if simulateNextSaveFailure {
            simulateNextSaveFailure = false
            lastErrorMessage = ListenStoreError.simulatedSaveFailure.localizedDescription
            throw ListenStoreError.simulatedSaveFailure
        }
        try validate(card)
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            let previousFilename = cards[index].windowPhotoFilename
            if previousFilename != card.windowPhotoFilename, let previousFilename {
                WindowPhotoStore.delete(filename: previousFilename)
            }
            cards[index] = card
        } else {
            cards.append(card)
        }
        favoriteShape = card.soundShape
        awardBadges(after: card)
        try persist()
        lastErrorMessage = nil
    }

    func archive(id: UUID) throws {
        guard let index = cards.firstIndex(where: { $0.id == id }) else {
            throw ListenStoreError.cardNotFound
        }
        cards[index].status = .archived
        awardBadge(.archivedMemory)
        try persist()
    }

    func delete(id: UUID) throws {
        guard let card = cards.first(where: { $0.id == id }) else {
            throw ListenStoreError.cardNotFound
        }
        if let filename = card.windowPhotoFilename {
            WindowPhotoStore.delete(filename: filename)
        }
        cards.removeAll { $0.id == id }
        try persist()
    }

    func persistWindowPhoto(data: Data, cardID: UUID) throws -> String {
        try WindowPhotoStore.save(data: data, cardID: cardID)
    }

    func resetForPreview() {
        cards = []
        badges = []
        favoriteShape = nil
        lastErrorMessage = nil
    }

    private func validate(_ card: ListenCard) throws {
        if card.note.count > 240 {
            lastErrorMessage = ListenStoreError.noteTooLong.localizedDescription
            throw ListenStoreError.noteTooLong
        }
    }

    private func awardBadges(after card: ListenCard) {
        awardBadge(.firstDawn)
        let directions = Set(cards.map(\.direction))
        if directions.count >= 3 {
            awardBadge(.threeDirections)
        }
        if Calendar.current.isDateInWeekend(card.heardAt) {
            awardBadge(.weekendRoost)
        }
    }

    private func awardBadge(_ type: SoundBadgeType) {
        guard !badges.contains(where: { $0.type == type }) else { return }
        badges.append(SoundBadge(type: type, earnedAt: Date()))
    }

    private func load() {
        do {
            guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
            let data = try Data(contentsOf: storageURL)
            let state = try decoder.decode(PersistedState.self, from: data)
            cards = state.cards
            badges = state.badges
            favoriteShape = state.favoriteShape
        } catch {
            lastErrorMessage = "Saved listen cards could not be loaded. Start a new private card or try again later."
            cards = []
            badges = []
            favoriteShape = nil
        }
    }

    private func persist() throws {
        do {
            let directory = storageURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let state = PersistedState(cards: cards, badges: badges, favoriteShape: favoriteShape)
            let data = try encoder.encode(state)
            try data.write(to: storageURL, options: [.atomic])
        } catch {
            lastErrorMessage = "WindowBird could not write to local storage. Your free flow is still available."
            throw error
        }
    }

    private static func defaultStorageURL() -> URL {
        if ProcessInfo.processInfo.arguments.contains("--windowbird-ui-test-store") {
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("WindowBirdChorusCardsUITests", isDirectory: true)
                .appendingPathComponent("listen-store.json")
            if ProcessInfo.processInfo.arguments.contains("--reset-windowbird-store") {
                try? FileManager.default.removeItem(at: url)
            }
            return url
        }
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base
            .appendingPathComponent("WindowBirdChorusCards", isDirectory: true)
            .appendingPathComponent("listen-store.json")
    }
}
