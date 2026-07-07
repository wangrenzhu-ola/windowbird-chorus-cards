import Foundation

enum AppPermissions {
    enum UsageDescription {
        static let photoLibraryRead =
            "WindowBird Chorus Cards reads your photo library only when you choose a window view image for a private listen card, so you can pair outside scenery with the rhythm and direction you heard."

        static let photoLibraryAdd =
            "WindowBird lets you save a window view photo from a listen card back to your photo library when you tap Export Window View, keeping the image outside your private sound map."

        static let camera =
            "WindowBird uses the camera when you capture a window view while logging birdsong rhythm, direction, weather, and mood. The photo stays in your private listen card on this device."

        static let microphone =
            "WindowBird declares microphone access for optional window birdsong listening helpers. You still choose the sound shape, direction, weather, and mood yourself, and audio is never uploaded."

        static let tracking =
            "WindowBird uses this permission to measure whether Premium Dawn Pack offers are helpful after you explore your private morning chorus and neighborhood sound map. Your listen cards and window view photos are never sold."
    }

    static let plistKeys: [String: String] = [
        "NSPhotoLibraryUsageDescription": UsageDescription.photoLibraryRead,
        "NSPhotoLibraryAddUsageDescription": UsageDescription.photoLibraryAdd,
        "NSCameraUsageDescription": UsageDescription.camera,
        "NSMicrophoneUsageDescription": UsageDescription.microphone,
        "NSUserTrackingUsageDescription": UsageDescription.tracking
    ]
}
