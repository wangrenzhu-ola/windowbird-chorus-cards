import SwiftUI

@main
struct WindowBirdChorusCardsApp: App {
    @State private var listenStore = ListenStore()
    @State private var premiumStore = PremiumStore()

    var body: some Scene {
        WindowGroup {
            AppShell()
                .environment(listenStore)
                .environment(premiumStore)
        }
    }
}
