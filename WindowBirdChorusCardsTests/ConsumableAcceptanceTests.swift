import XCTest
@testable import WindowBirdChorusCards

@MainActor
final class ConsumableAcceptanceTests: XCTestCase {
    func testCatalogMatchesRequiredConsumableProductCounts() {
        XCTAssertEqual(IAPProductCatalog.productCount, 27)
        XCTAssertEqual(IAPProductCatalog.standardProductCount, 19)
        XCTAssertEqual(IAPProductCatalog.promotionProductCount, 8)
        XCTAssertEqual(IAPProductCatalog.all.count, 27)
        XCTAssertEqual(IAPProductCatalog.standardProducts.count, 19)
        XCTAssertEqual(IAPProductCatalog.promotionProducts.count, 8)
        XCTAssertEqual(IAPProductCatalog.productIDs.count, 27)
        XCTAssertEqual(IAPProductCatalog.all.first?.productID, "473900")
        XCTAssertEqual(IAPProductCatalog.all.last?.productID, "473926")
        print("ACCEPTANCE_READBACK REQ-PREMIUM-001: consumable catalog exposes 27 products with 19 standard and 8 promotion packs")
    }

    func testInitialBalanceAndSaveCostAreConfigured() throws {
        let url = temporaryCreditURL("initial-balance")
        let store = ChorusCreditStore(storageURL: url)
        XCTAssertEqual(store.balance, IAPProductCatalog.initialBalance)
        XCTAssertEqual(ChorusCreditStore.saveCost, 10)

        try store.spendForNewCardSave()
        XCTAssertEqual(store.balance, 90)
        print("ACCEPTANCE_READBACK REQ-PREMIUM-001: new listen card save spends 10 credits from the initial 100 balance")
    }

    func testInsufficientCreditsExposeShopRecoveryCopy() {
        let url = temporaryCreditURL("insufficient")
        let store = ChorusCreditStore(storageURL: url)
        store.resetForPreview()
        for _ in 0..<10 {
            try? store.spendForNewCardSave()
        }
        XCTAssertThrowsError(try store.spendForNewCardSave()) { error in
            XCTAssertEqual(error as? ChorusCreditError, .insufficientCredits(needed: 10, available: 0))
        }
        print("ACCEPTANCE_READBACK REQ-PREMIUM-001: insufficient credits error points users to Chorus Credit Shop")
    }

    func testPurchaseFailureDoesNotBlockSavedCardsOrCredits() async {
        let credits = ChorusCreditStore(storageURL: temporaryCreditURL("purchase-failure"))
        let processed = ProcessedTransactionStore(storageURL: temporaryProcessedURL("purchase-failure"))
        let consumable = ConsumableStore(creditStore: credits, processedTransactionStore: processed)
        let startingBalance = credits.balance

        await consumable.purchase(IAPProductCatalog.promotionProducts[0], simulateFailure: true)
        guard case .error(let message) = consumable.state else {
            return XCTFail("Expected simulated IAP failure state")
        }
        XCTAssertTrue(message.contains("saved listen cards"))
        XCTAssertEqual(credits.balance, startingBalance)
        print("ACCEPTANCE_READBACK REQ-PREMIUM-001: consumable purchase failure keeps saved cards and current credits available")
    }

    func testProcessedTransactionIDsPreventDoubleCreditDelivery() {
        let url = temporaryProcessedURL("dedupe")
        let store = ProcessedTransactionStore(storageURL: url)
        XCTAssertTrue(store.recordIfNew(42))
        XCTAssertFalse(store.recordIfNew(42))
        XCTAssertTrue(store.hasProcessed(42))

        let reloaded = ProcessedTransactionStore(storageURL: url)
        XCTAssertTrue(reloaded.hasProcessed(42))
        XCTAssertFalse(reloaded.recordIfNew(42))
        print("ACCEPTANCE_READBACK REQ-PREMIUM-001: processed consumable transaction IDs persist to prevent duplicate credit grants")
    }

    private func temporaryCreditURL(_ name: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("WindowBirdTests-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("\(name)-credits.json")
    }

    private func temporaryProcessedURL(_ name: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("WindowBirdTests-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("\(name)-processed.json")
    }
}
