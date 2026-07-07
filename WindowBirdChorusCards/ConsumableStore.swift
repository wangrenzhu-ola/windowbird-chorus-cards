import Foundation
import Observation
import StoreKit

enum ConsumableStoreState: Equatable {
    case idle
    case loading
    case purchasing(String)
    case error(String)

    var displayName: String {
        switch self {
        case .idle: "Ready"
        case .loading: "Loading Shop"
        case .purchasing: "Purchasing"
        case .error: "Shop Needs Attention"
        }
    }
}

@Observable
final class ConsumableStore {
    private let creditStore: ChorusCreditStore
    private let processedTransactionStore: ProcessedTransactionStore
    private(set) var products: [Product] = []
    private(set) var state: ConsumableStoreState = .idle
    private(set) var lastErrorMessage: String?
    private(set) var lastSuccessMessage: String?

    init(
        creditStore: ChorusCreditStore,
        processedTransactionStore: ProcessedTransactionStore = ProcessedTransactionStore()
    ) {
        self.creditStore = creditStore
        self.processedTransactionStore = processedTransactionStore
        Task {
            await processUnfinishedTransactions()
            await listenForTransactions()
        }
    }

    func loadProducts() async {
        state = .loading
        lastSuccessMessage = nil
        do {
            let loaded = try await Product.products(for: IAPProductCatalog.productIDs)
            let consumables = loaded.filter { $0.type == .consumable }
            products = consumables
                .sorted { lhs, rhs in
                    let left = IAPProductCatalog.item(for: lhs.id)?.creditAmount ?? 0
                    let right = IAPProductCatalog.item(for: rhs.id)?.creditAmount ?? 0
                    return left < right
                }
            state = .idle
            lastErrorMessage = nil
        } catch {
            setError("Chorus credit packs are unavailable right now. You can still review saved listen cards.")
        }
    }

    func purchase(_ item: IAPCatalogItem, simulateFailure: Bool = false) async {
        if simulateFailure {
            setError("Purchase could not be completed. Your saved listen cards and current credits are still available.")
            return
        }
        guard let product = products.first(where: { $0.id == item.productID }) else {
            setError("This credit pack is not available yet. Try again after the shop finishes loading.")
            return
        }
        await purchase(product: product, catalogItem: item)
    }

    func purchase(product: Product, catalogItem: IAPCatalogItem) async {
        guard product.type == .consumable else {
            setError("Only consumable Chorus credit packs can be purchased in this shop.")
            return
        }

        state = .purchasing(catalogItem.creditTitle)
        lastSuccessMessage = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let delivered = await handle(
                    transactionResult: verification,
                    catalogItem: catalogItem,
                    announceSuccess: true
                )
                state = .idle
                lastErrorMessage = nil
                if !delivered {
                    lastSuccessMessage = "This Chorus credit purchase was already applied to your balance."
                }
            case .userCancelled:
                state = .idle
                lastErrorMessage = "Purchase cancelled. Your current Chorus Credits were not changed."
            case .pending:
                state = .idle
                lastErrorMessage = "Purchase is pending approval. Credits will appear after the transaction completes."
            @unknown default:
                setError("Purchase could not be completed. Your saved listen cards and current credits are still available.")
            }
        } catch {
            setError("Purchase could not be completed. Your saved listen cards and current credits are still available.")
        }
    }

    func product(for item: IAPCatalogItem) -> Product? {
        products.first { $0.id == item.productID }
    }

    func displayPrice(for item: IAPCatalogItem) -> String {
        product(for: item)?.displayPrice ?? item.referencePriceUSD
    }

    private func processUnfinishedTransactions() async {
        for await result in Transaction.unfinished {
            _ = await handle(transactionResult: result, announceSuccess: false)
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            _ = await handle(transactionResult: result, announceSuccess: true)
        }
    }

    @discardableResult
    private func handle(
        transactionResult: VerificationResult<Transaction>,
        catalogItem: IAPCatalogItem? = nil,
        announceSuccess: Bool
    ) async -> Bool {
        guard let transaction = try? checkVerified(transactionResult),
              let item = catalogItem ?? IAPProductCatalog.item(for: transaction.productID) else {
            return false
        }

        let isNew = processedTransactionStore.recordIfNew(transaction.id)
        if isNew {
            creditStore.addCredits(item.creditAmount)
        }

        await transaction.finish()

        if isNew && announceSuccess {
            lastSuccessMessage = "Added \(item.creditAmount.formatted()) Chorus Credits. Balance is now \(creditStore.balance.formatted())."
        }

        return isNew
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.notAvailableInStorefront
        case .verified(let safe):
            return safe
        }
    }

    private func setError(_ message: String) {
        state = .error(message)
        lastErrorMessage = message
    }
}
