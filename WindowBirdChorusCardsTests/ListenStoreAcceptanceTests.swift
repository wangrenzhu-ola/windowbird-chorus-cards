import XCTest
import UIKit
@testable import WindowBirdChorusCards

@MainActor
final class ListenStoreAcceptanceTests: XCTestCase {
    func testCRUDPersistenceArchiveAndDeleteFlow() throws {
        let url = temporaryStoreURL("crud-persistence")
        let store = ListenStore(storageURL: url)

        var draft = ListenDraft()
        draft.soundShape = .chirpPair
        draft.direction = .east
        draft.weather = .paleSun
        draft.mood = .curious
        draft.note = "Heard two bright notes near the kitchen window."

        let created = draft.makeCard()
        try store.save(created)
        XCTAssertEqual(store.activeCards.count, 1)
        XCTAssertEqual(store.badges.map(\.type), [.firstDawn])

        var edited = created
        edited.direction = .northwest
        edited.soundShape = .fallingWhistle
        edited.note = "Edited after a second listen from the northwest window."
        try store.save(edited)
        XCTAssertEqual(store.card(with: created.id)?.direction, .northwest)

        let reloaded = ListenStore(storageURL: url)
        XCTAssertEqual(reloaded.activeCards.count, 1)
        XCTAssertEqual(reloaded.activeCards.first?.soundShape, .fallingWhistle)
        XCTAssertEqual(reloaded.favoriteShape, .fallingWhistle)

        try reloaded.archive(id: created.id)
        XCTAssertEqual(reloaded.activeCards.count, 0)
        XCTAssertEqual(reloaded.archivedCards.count, 1)
        XCTAssertTrue(reloaded.badges.contains { $0.type == .archivedMemory })

        try reloaded.delete(id: created.id)
        XCTAssertTrue(reloaded.cards.isEmpty)
        print("ACCEPTANCE_READBACK REQ-CRUD-001 REQ-PERSIST-001: created, edited, reloaded, archived, and deleted one ListenCard using local JSON at \(url.path)")
    }

    func testValidationAndSimulatedSaveFailureExposeRecoverableErrors() throws {
        let store = ListenStore(storageURL: temporaryStoreURL("errors"))
        var draft = ListenDraft()
        draft.note = String(repeating: "a", count: 241)

        XCTAssertThrowsError(try store.save(draft.makeCard())) { error in
            XCTAssertEqual(error as? ListenStoreError, .noteTooLong)
        }
        XCTAssertEqual(store.lastErrorMessage, ListenStoreError.noteTooLong.localizedDescription)

        draft.note = "Short private note."
        store.simulateNextSaveFailure = true
        XCTAssertThrowsError(try store.save(draft.makeCard())) { error in
            XCTAssertEqual(error as? ListenStoreError, .simulatedSaveFailure)
        }
        XCTAssertEqual(store.activeCards.count, 0)
        print("ACCEPTANCE_READBACK REQ-ERROR-001: note length validation and simulated save failure both returned en-US recovery messages")
    }

    func testWindowPhotoFilenamePersistsWithCard() throws {
        let url = temporaryStoreURL("window-photo")
        let store = ListenStore(storageURL: url)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
        let imageData = renderer.pngData { context in
            UIColor.cyan.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        }

        var draft = ListenDraft()
        draft.note = "Morning window with pale sun."
        let cardID = UUID()
        let filename = try store.persistWindowPhoto(data: imageData, cardID: cardID)

        var card = draft.makeCard(id: cardID)
        card.windowPhotoFilename = filename
        try store.save(card)

        let reloaded = ListenStore(storageURL: url)
        XCTAssertEqual(reloaded.activeCards.first?.windowPhotoFilename, filename)
        XCTAssertNotNil(WindowPhotoStore.load(filename: filename))

        try reloaded.delete(id: cardID)
        XCTAssertNil(WindowPhotoStore.load(filename: filename))
        print("ACCEPTANCE_READBACK REQ-PERSIST-001: window view photo filename persisted with ListenCard and deleted with card")
    }

    private func temporaryStoreURL(_ name: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("WindowBirdTests-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("\(name).json")
    }
}
