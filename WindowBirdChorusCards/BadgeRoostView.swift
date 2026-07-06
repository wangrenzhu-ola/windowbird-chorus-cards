import SwiftUI

struct BadgeRoostView: View {
    @Environment(ListenStore.self) private var listenStore
    @Environment(PremiumStore.self) private var premiumStore
    @Binding var selectedTab: AppTab
    @State private var showFailureCopy = false

    var body: some View {
        ZStack {
            DawnGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    badgeGrid
                    paywall
                    freeFlowReminder
                }
                .padding(20)
            }
        }
        .navigationTitle("Badge Roost")
        .toolbarTitleDisplayMode(.inline)
        .task {
            await premiumStore.loadProducts()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Badge Roost")
                .font(.title.bold())
            Text("Collect quiet exploration badges from saved listens. Premium adds visual packs only; the core flow stays free.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var badgeGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
            ForEach(SoundBadgeType.allCases) { badgeType in
                let earned = listenStore.badges.first { $0.type == badgeType }
                GlassSurface(radius: 22) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: earned == nil ? "circle.dashed" : "rosette")
                            .font(.title2)
                            .foregroundStyle(earned == nil ? .secondary : Color(red: 0.78, green: 0.34, blue: 0.20))
                        Text(badgeType.displayName)
                            .font(.headline)
                        Text(earned == nil ? badgeType.description : "Earned for your private sound map.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 126, alignment: .leading)
                }
                .accessibilityLabel("Badge \(badgeType.displayName), \(earned == nil ? "locked" : "earned")")
            }
        }
    }

    private var paywall: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Premium Dawn Pack", systemImage: premiumStore.isUnlocked ? "checkmark.seal.fill" : "sparkles")
                        .font(.headline)
                    Spacer()
                    Text(premiumStore.accessState.displayName)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.thinMaterial, in: Capsule())
                }

                Text(premiumStore.paywallSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let message = premiumStore.lastErrorMessage ?? (showFailureCopy ? "Purchase could not be completed. Your free listening flow is still available." : nil) {
                    ErrorBanner(message: message)
                }

                HStack(spacing: 12) {
                    Button("Purchase Premium Pack") {
                        Task { await premiumStore.purchasePremiumPack() }
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Purchase Premium Pack with StoreKit 2")

                    Button("Restore Purchase") {
                        Task { await premiumStore.restorePurchases() }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Restore Premium purchase")
                }

                Button("Simulate IAP Failure") {
                    showFailureCopy = true
                    Task { await premiumStore.purchasePremiumPack(simulateFailure: true) }
                }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundStyle(Color(red: 0.55, green: 0.22, blue: 0.13))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var freeFlowReminder: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 10) {
                Label("Free flow remains open", systemImage: "leaf.fill")
                    .font(.headline)
                Text(AppCopy.privacyBoundary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("Return to Morning Chorus") {
                    selectedTab = .morning
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
