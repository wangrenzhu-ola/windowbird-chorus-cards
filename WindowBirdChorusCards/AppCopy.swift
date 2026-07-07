import Foundation

enum AppCopy {
    static let privacyBoundary = "Listen cards, window view photos, and notes stay on this device. The listening flow does not require microphone recording. Credit purchases use StoreKit and do not restore previous balances."
    static let productName = "WindowBird Chorus Cards"
    static let privacyPolicyTitle = "Privacy Policy"
    static let userAgreementTitle = "User Agreement"
    static let privacyPolicyURL = URL(string: "https://windowbirdchoruscards.example/legal/privacy-policy")!
    static let userAgreementURL = URL(string: "https://windowbirdchoruscards.example/legal/user-agreement")!

    static let userVisibleSamples: [String] = [
        productName,
        "Morning Chorus",
        "Sound Shape Picker",
        "Window Listen Detail",
        "Neighborhood Sound Map",
        "Chorus Credit Shop",
        "Badge Roost",
        "Listen",
        "Exploration badges",
        "Start a Listen",
        "Continue to Listen Card",
        "Pick the rhythm you heard near your window, then turn it into a private chorus card.",
        "Chorus Credits",
        "Open Chorus Credit Shop",
        "Open Badge Roost",
        "Save Listen Card · 10 Credits",
        "Get Chorus Credits",
        "Recommended Packs",
        "Show All Credit Packs",
        "Buy Credits",
        "Window view",
        "Choose from Photos",
        "Capture Window View",
        "Export Window View",
        "Latest window view",
        "Window memory",
        "Your sound map is quiet for now.",
        "Save Changes",
        "Archive Card",
        "Delete Card",
        privacyPolicyTitle,
        userAgreementTitle,
        "Purchase could not be completed. Your saved listen cards and current credits are still available.",
        privacyBoundary
    ]
}
