import SwiftUI

@main
struct WindowBirdChorusCardsApp: App {
    @State private var listenStore: ListenStore
    @State private var creditStore: ChorusCreditStore
    @State private var consumableStore: ConsumableStore
    @State private var trackingAuthorizationService = TrackingAuthorizationService()

    init() {
        let credits = ChorusCreditStore()
        _listenStore = State(initialValue: ListenStore())
        _creditStore = State(initialValue: credits)
        _consumableStore = State(initialValue: ConsumableStore(creditStore: credits))
    }

    var body: some Scene {
        WindowGroup {
            AppShell()
                .environment(listenStore)
                .environment(creditStore)
                .environment(consumableStore)
                .task {
                    await trackingAuthorizationService.requestIfNeeded()
                }
        }
    }
}
