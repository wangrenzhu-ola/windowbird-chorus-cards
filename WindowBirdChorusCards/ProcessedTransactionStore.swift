import Foundation

final class ProcessedTransactionStore {
    private struct PersistedState: Codable {
        var processedTransactionIDs: [UInt64]
    }

    private var processedIDs: Set<UInt64>
    private let storageURL: URL

    init(storageURL: URL? = nil) {
        self.storageURL = storageURL ?? Self.defaultStorageURL()
        if Self.shouldResetForUITest {
            processedIDs = []
            try? persist()
        } else if let loaded = Self.loadProcessedIDs(from: self.storageURL) {
            processedIDs = loaded
        } else {
            processedIDs = []
        }
    }

    func hasProcessed(_ transactionID: UInt64) -> Bool {
        processedIDs.contains(transactionID)
    }

    @discardableResult
    func recordIfNew(_ transactionID: UInt64) -> Bool {
        guard !processedIDs.contains(transactionID) else { return false }
        processedIDs.insert(transactionID)
        try? persist()
        return true
    }

    private func persist() throws {
        let directory = storageURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let state = PersistedState(processedTransactionIDs: Array(processedIDs).sorted())
        let data = try JSONEncoder().encode(state)
        try data.write(to: storageURL, options: [.atomic])
    }

    private static func loadProcessedIDs(from url: URL) -> Set<UInt64>? {
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let state = try? JSONDecoder().decode(PersistedState.self, from: data) else {
            return nil
        }
        return Set(state.processedTransactionIDs)
    }

    private static var shouldResetForUITest: Bool {
        ProcessInfo.processInfo.arguments.contains("--reset-windowbird-store")
    }

    private static func defaultStorageURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base
            .appendingPathComponent("WindowBirdChorusCards", isDirectory: true)
            .appendingPathComponent("processed-iap-transactions.json")
    }
}
