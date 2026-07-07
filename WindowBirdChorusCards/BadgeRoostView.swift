import SwiftUI

struct BadgeRoostView: View {
    @Environment(ListenStore.self) private var listenStore
    @Environment(ChorusCreditStore.self) private var creditStore
    @Environment(ConsumableStore.self) private var consumableStore
    @Binding var selectedTab: AppTab
    @State private var showFailureCopy = false

    var body: some View {
        ZStack {
            DawnGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    balanceCard
                    saveCostCard
                    shopSection(title: "Limited Offers", items: IAPProductCatalog.promotionProducts)
                    shopSection(title: "Chorus Credit Packs", items: IAPProductCatalog.standardProducts)
                    badgeGrid
                    freeFlowReminder
                }
                .padding(20)
            }
        }
        .navigationTitle("Badge Roost")
        .toolbarTitleDisplayMode(.inline)
        .task {
            await consumableStore.loadProducts()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Badge Roost")
                .font(.title.bold())
                .foregroundStyle(Color.wbText)
            Text("Collect badges from saved listens and buy Chorus Credits when you need more room for new cards.")
                .font(.body)
                .foregroundStyle(Color.wbMuted)
        }
    }

    private var balanceCard: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 12) {
                Label("Chorus Credit Shop", systemImage: "circle.hexagongrid.fill")
                    .font(.headline)
                HStack {
                    ChorusCreditBalanceBadge(balance: creditStore.balance)
                    Spacer()
                    Text(consumableStore.state.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.wbMuted)
                }
                if let message = consumableStore.lastSuccessMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(Color.wbLime)
                }
                if let message = consumableStore.lastErrorMessage ?? (showFailureCopy ? "Purchase could not be completed. Your saved listen cards and current credits are still available." : nil) {
                    ErrorBanner(message: message)
                }
                Button("Simulate IAP Failure") {
                    showFailureCopy = true
                    Task {
                        await consumableStore.purchase(IAPProductCatalog.promotionProducts[0], simulateFailure: true)
                    }
                }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundStyle(Color.wbAmber)
                .accessibilityLabel("Simulate IAP Failure")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var saveCostCard: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 8) {
                Label("Easy to spot spend", systemImage: "tray.and.arrow.down.fill")
                    .font(.headline)
                Text("Each new listen card costs \(ChorusCreditStore.saveCost.formatted()) Chorus Credits when you tap Save in Window Listen Detail. Editing an existing card is free.")
                    .font(.subheadline)
                    .foregroundStyle(Color.wbMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func shopSection(title: String, items: [IAPCatalogItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(Color.wbText)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 168), spacing: 12)], spacing: 12) {
                ForEach(items) { item in
                    ChorusCreditPackCard(
                        item: item,
                        displayPrice: consumableStore.displayPrice(for: item),
                        isPurchasing: isPurchasing(item)
                    ) {
                        Task { await consumableStore.purchase(item) }
                    }
                }
            }
        }
    }

    private func isPurchasing(_ item: IAPCatalogItem) -> Bool {
        if case .purchasing(let title) = consumableStore.state {
            return title == item.creditTitle
        }
        return false
    }

    private var badgeGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
            ForEach(SoundBadgeType.allCases) { badgeType in
                let earned = listenStore.badges.first { $0.type == badgeType }
                GlassSurface(radius: 22) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: earned == nil ? "circle.dashed" : "rosette")
                            .font(.title2)
                            .foregroundStyle(earned == nil ? Color.wbMuted : Color.wbLime)
                        Text(badgeType.displayName)
                            .font(.headline)
                        Text(earned == nil ? badgeType.description : "Earned for your private sound map.")
                            .font(.caption)
                            .foregroundStyle(Color.wbMuted)
                    }
                    .frame(maxWidth: .infinity, minHeight: 126, alignment: .leading)
                }
                .accessibilityLabel("Badge \(badgeType.displayName), \(earned == nil ? "locked" : "earned")")
            }
        }
    }

    private var freeFlowReminder: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 10) {
                Label("Private cards stay local", systemImage: "leaf.fill")
                    .font(.headline)
                Text(AppCopy.privacyBoundary)
                    .font(.subheadline)
                    .foregroundStyle(Color.wbMuted)
                Button("Return to Morning Chorus") {
                    selectedTab = .morning
                }
                .buttonStyle(.bordered)
                .tint(Color.wbCyan)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
