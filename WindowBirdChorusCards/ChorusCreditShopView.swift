import SwiftUI

struct ChorusCreditShopView: View {
    @Environment(ChorusCreditStore.self) private var creditStore
    @Environment(ConsumableStore.self) private var consumableStore
    @State private var showAllPacks = false
    #if DEBUG
    @State private var showFailureCopy = false
    #endif

    var body: some View {
        ZStack {
            DawnGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    balanceCard
                    saveCostCard
                    shopSection(title: "Recommended Packs", items: IAPProductCatalog.featuredProducts)
                    if showAllPacks {
                        shopSection(title: "More Credit Packs", items: IAPProductCatalog.additionalProducts)
                    } else {
                        Button("Show All Credit Packs") {
                            withAnimation { showAllPacks = true }
                        }
                        .buttonStyle(.bordered)
                        .tint(Color.wbCyan)
                        .frame(maxWidth: .infinity)
                    }
                    legalCard
                }
                .padding(20)
            }
        }
        .navigationTitle("Chorus Credit Shop")
        .toolbarTitleDisplayMode(.inline)
        .task {
            await consumableStore.loadProducts()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Chorus Credit Shop")
                .font(.title.bold())
                .foregroundStyle(Color.wbText)
            Text("Buy credits for new listen cards. Each new save costs \(ChorusCreditStore.saveCost.formatted()) credits; editing an existing card is free.")
                .font(.body)
                .foregroundStyle(Color.wbMuted)
        }
    }

    private var balanceCard: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 12) {
                Label("Your balance", systemImage: "circle.hexagongrid.fill")
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
                if let message = consumableStore.lastErrorMessage ?? debugFailureMessage {
                    ErrorBanner(message: message)
                }
                #if DEBUG
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
                #endif
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    #if DEBUG
    private var debugFailureMessage: String? {
        showFailureCopy ? "Purchase could not be completed. Your saved listen cards and current credits are still available." : nil
    }
    #else
    private var debugFailureMessage: String? { nil }
    #endif

    private var saveCostCard: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 8) {
                Label("How credits are used", systemImage: "tray.and.arrow.down.fill")
                    .font(.headline)
                Text("You start with \(IAPProductCatalog.initialBalance.formatted()) credits, enough for \(IAPProductCatalog.initialBalance / IAPProductCatalog.saveCost) new listen cards.")
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

    private var legalCard: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 10) {
                Label("Legal", systemImage: "doc.text.fill")
                    .font(.headline)
                LegalLinksSection()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
