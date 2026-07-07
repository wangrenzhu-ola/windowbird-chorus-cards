import AppTrackingTransparency
import Foundation
import Observation

@Observable
final class TrackingAuthorizationService {
    private(set) var authorizationStatus: ATTrackingManager.AuthorizationStatus = .notDetermined

    func requestIfNeeded() async {
        guard !Self.isUITestLaunch else { return }
        try? await Task.sleep(nanoseconds: 900_000_000)

        let current = ATTrackingManager.trackingAuthorizationStatus
        authorizationStatus = current
        guard current == .notDetermined else { return }

        authorizationStatus = await ATTrackingManager.requestTrackingAuthorization()
    }

    private static var isUITestLaunch: Bool {
        ProcessInfo.processInfo.arguments.contains("--windowbird-ui-test-store")
    }
}
