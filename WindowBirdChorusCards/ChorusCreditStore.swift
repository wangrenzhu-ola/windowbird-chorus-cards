import Foundation
import Observation

enum ChorusCreditError: LocalizedError, Equatable {
    case insufficientCredits(needed: Int, available: Int)

    var errorDescription: String? {
        switch self {
        case .insufficientCredits(let needed, let available):
            "Saving a new listen card costs \(needed) Chorus Credits. You have \(available). Open the Shop tab to add more."
        }
    }
}

@Observable
final class ChorusCreditStore {
    private struct PersistedState: Codable {
        var balance: Int
    }

    private(set) var balance: Int
    private let storageURL: URL

    init(storageURL: URL? = nil) {
        self.storageURL = storageURL ?? Self.defaultStorageURL()
        if Self.shouldResetForUITest {
            balance = IAPProductCatalog.initialBalance
            try? persist()
        } else {
            balance = Self.loadBalance(from: self.storageURL) ?? IAPProductCatalog.initialBalance
        }
    }

    static var saveCost: Int { IAPProductCatalog.saveCost }

    func addCredits(_ amount: Int) {
        guard amount > 0 else { return }
        balance += amount
        try? persist()
    }

    func spendForNewCardSave() throws {
        let cost = Self.saveCost
        guard balance >= cost else {
            throw ChorusCreditError.insufficientCredits(needed: cost, available: balance)
        }
        balance -= cost
        try persist()
    }

    func resetForPreview() {
        balance = IAPProductCatalog.initialBalance
        try? persist()
    }

    private func persist() throws {
        let directory = storageURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(PersistedState(balance: balance))
        try data.write(to: storageURL, options: [.atomic])
    }

    private static func loadBalance(from url: URL) -> Int? {
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let state = try? JSONDecoder().decode(PersistedState.self, from: data) else {
            return nil
        }
        return state.balance
    }

    private static var shouldResetForUITest: Bool {
        ProcessInfo.processInfo.arguments.contains("--reset-windowbird-store")
    }

    private static func defaultStorageURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base
            .appendingPathComponent("WindowBirdChorusCards", isDirectory: true)
            .appendingPathComponent("chorus-credits.json")
    }
}
