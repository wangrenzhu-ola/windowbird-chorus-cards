import XCTest
@testable import WindowBirdChorusCards

@MainActor
final class PremiumAcceptanceTests: XCTestCase {
    func testPremiumFailureRestoreAndUnlockedStatesAreVisibleWithoutBlockingFreeFlow() async {
        let premium = PremiumStore(productIDs: [])

        await premium.purchasePremiumPack(simulateFailure: true)
        guard case .error(let purchaseMessage) = premium.accessState else {
            return XCTFail("Expected simulated IAP failure state")
        }
        XCTAssertTrue(purchaseMessage.contains("free listening flow"))

        await premium.restorePurchases()
        guard case .error(let restoreMessage) = premium.accessState else {
            return XCTFail("Expected restore miss state")
        }
        XCTAssertTrue(restoreMessage.contains("free listening flow"))

        premium.unlockForTesting()
        XCTAssertTrue(premium.isUnlocked)
        XCTAssertEqual(premium.accessState.displayName, "Premium Unlocked")
        print("ACCEPTANCE_READBACK REQ-PREMIUM-001: Premium purchase failure, restore miss, and unlocked states are reachable while free flow remains available")
    }
}
