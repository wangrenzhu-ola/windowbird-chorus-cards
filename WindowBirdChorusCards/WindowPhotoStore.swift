import Foundation
import UIKit

enum WindowPhotoStore {
    static func save(data: Data, cardID: UUID) throws -> String {
        let directory = try photosDirectory()
        let filename = "\(cardID.uuidString).jpg"
        let url = directory.appendingPathComponent(filename)
        try data.write(to: url, options: [.atomic])
        return filename
    }

    static func load(filename: String) -> UIImage? {
        let url = photosDirectoryURL().appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(data: (try? Data(contentsOf: url)) ?? Data())
    }

    static func delete(filename: String) {
        let url = photosDirectoryURL().appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    private static func photosDirectory() throws -> URL {
        let directory = photosDirectoryURL()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private static func photosDirectoryURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base
            .appendingPathComponent("WindowBirdChorusCards", isDirectory: true)
            .appendingPathComponent("window-photos", isDirectory: true)
    }
}
