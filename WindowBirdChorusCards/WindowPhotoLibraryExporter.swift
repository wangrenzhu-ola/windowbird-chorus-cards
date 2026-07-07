import Photos
import UIKit

enum WindowPhotoLibraryExportError: LocalizedError {
    case accessDenied
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            "WindowBird could not save this window view to Photos. Allow photo library access in Settings, then try Export Window View again."
        case .saveFailed:
            "The window view photo could not be written to your photo library. Try again from Window Listen Detail."
        }
    }
}

enum WindowPhotoLibraryExporter {
    static func export(_ image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized else {
            throw WindowPhotoLibraryExportError.accessDenied
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: WindowPhotoLibraryExportError.saveFailed)
                }
            })
        }
    }
}
