import Foundation
import Observation
import StoreKit

enum PremiumAccessState: Equatable {
    case locked
    case unlocked
    case loading
    case error(String)

    var displayName: String {
        switch self {
        case .locked: "Premium Locked"
        case .unlocked: "Premium Unlocked"
        case .loading: "Checking Premium"
        case .error: "Premium Needs Attention"
        }
    }
}

@Observable
final class PremiumStore {
    private let productIDs: Set<String>
    private(set) var products: [Product] = []
    private(set) var accessState: PremiumAccessState = .locked
    private(set) var lastErrorMessage: String?

    init(productIDs: Set<String> = [AppCopy.premiumProductID]) {
        self.productIDs = productIDs
    }

    var isUnlocked: Bool {
        if case .unlocked = accessState { return true }
        return false
    }

    var paywallSubtitle: String {
        if let product = products.first {
            return "Unlock extra dawn themes and sticker roosts with \(product.displayPrice)."
        }
        return "Unlock extra dawn themes and sticker roosts when the StoreKit 2 product is configured."
    }

    func loadProducts() async {
        accessState = .loading
        do {
            products = try await Product.products(for: productIDs)
            await refreshEntitlements()
            if !isUnlocked {
                accessState = .locked
            }
        } catch {
            setError("Premium products are unavailable right now. You can keep using the free listen flow.")
        }
    }

    func purchasePremiumPack(simulateFailure: Bool = false) async {
        if simulateFailure {
            setError("Purchase could not be completed. Your free listening flow is still available.")
            return
        }
        guard let product = products.first else {
            setError("Purchase is unavailable until the StoreKit 2 product is configured. Your free listening flow is still available.")
            return
        }
        accessState = .loading
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                accessState = .unlocked
                lastErrorMessage = nil
            case .userCancelled:
                accessState = .locked
                lastErrorMessage = "Purchase cancelled. Your free listening flow is still available."
            case .pending:
                accessState = .locked
                lastErrorMessage = "Purchase is pending approval. You can keep using the free listen flow."
            @unknown default:
                setError("Purchase could not be completed. Your free listening flow is still available.")
            }
        } catch {
            setError("Purchase could not be completed. Your free listening flow is still available.")
        }
    }

    func restorePurchases() async {
        accessState = .loading
        await refreshEntitlements()
        if !isUnlocked {
            setError("No premium purchase was found to restore. The free listening flow is still available.")
        }
    }

    func unlockForTesting() {
        accessState = .unlocked
        lastErrorMessage = nil
    }

    private func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if productIDs.contains(transaction.productID) {
                accessState = .unlocked
                lastErrorMessage = nil
                return
            }
        }
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
        accessState = .error(message)
        lastErrorMessage = message
    }
}
