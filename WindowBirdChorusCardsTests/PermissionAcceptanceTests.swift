import XCTest
@testable import WindowBirdChorusCards

final class PermissionAcceptanceTests: XCTestCase {
    func testPermissionDescriptionsAreAppSpecificAndComplete() {
        XCTAssertTrue(AppPermissions.UsageDescription.photoLibraryRead.contains("window view"))
        XCTAssertTrue(AppPermissions.UsageDescription.photoLibraryRead.contains("listen card"))
        XCTAssertTrue(AppPermissions.UsageDescription.photoLibraryAdd.contains("Export Window View"))
        XCTAssertTrue(AppPermissions.UsageDescription.camera.contains("birdsong rhythm"))
        XCTAssertTrue(AppPermissions.UsageDescription.microphone.contains("sound shape"))
        XCTAssertTrue(AppPermissions.UsageDescription.tracking.contains("Premium Dawn Pack"))

        XCTAssertEqual(AppPermissions.plistKeys.count, 5)
        XCTAssertEqual(
            Set(AppPermissions.plistKeys.keys),
            Set([
                "NSPhotoLibraryUsageDescription",
                "NSPhotoLibraryAddUsageDescription",
                "NSCameraUsageDescription",
                "NSMicrophoneUsageDescription",
                "NSUserTrackingUsageDescription"
            ])
        )
        print("ACCEPTANCE_READBACK REQ-PRIVACY-001: photo, camera, microphone, and tracking permission copy is app-specific")
    }

    func testProjectInfoPlistIncludesPermissionDescriptions() throws {
        let project = try Self.loadProjectPBXProj()
        let trackingSource = try Self.loadAppSource(named: "TrackingAuthorizationService.swift")

        for (key, value) in AppPermissions.plistKeys {
            XCTAssertTrue(project.contains("INFOPLIST_KEY_\(key) = \"\(value)\""), "Missing plist key \(key)")
        }
        XCTAssertTrue(trackingSource.contains("ATTrackingManager.requestTrackingAuthorization"))
        print("ACCEPTANCE_READBACK REQ-PRIVACY-001: Info.plist permission keys and ATT request are present in the project")
    }

    private static func loadProjectPBXProj() throws -> String {
        let root = try locateRepositoryRoot()
        let projectURL = root.appendingPathComponent("WindowBirdChorusCards.xcodeproj/project.pbxproj")
        return try String(contentsOf: projectURL, encoding: .utf8)
    }

    private static func loadAppSource(named filename: String) throws -> String {
        let root = try locateRepositoryRoot()
        let sourceURL = root.appendingPathComponent("WindowBirdChorusCards/\(filename)")
        return try String(contentsOf: sourceURL, encoding: .utf8)
    }

    private static func locateRepositoryRoot() throws -> URL {
        if let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"] {
            return URL(fileURLWithPath: srcRoot, isDirectory: true)
        }

        var url = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let fileManager = FileManager.default
        for _ in 0..<8 {
            let candidate = url.appendingPathComponent("WindowBirdChorusCards.xcodeproj")
            if fileManager.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        throw NSError(domain: "PermissionAcceptanceTests", code: 1)
    }
}
