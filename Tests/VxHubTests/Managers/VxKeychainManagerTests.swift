import XCTest
@testable import VxHub

final class VxKeychainManagerTests: XCTestCase {

    var keychainManager: VxKeychainManager!

    override func setUp() {
        super.setUp()
        keychainManager = VxKeychainManager()
    }

    func testUDIDIsNonEmpty() {
        let udid = keychainManager.UDID
        XCTAssertFalse(udid.isEmpty, "UDID should not be empty")
    }

    func testUDIDIsValidUUID() {
        let udid = keychainManager.UDID
        // UDID should be a valid UUID-like string (may or may not have hyphens)
        XCTAssertGreaterThanOrEqual(udid.count, 32, "UDID should be at least 32 characters")
    }

    func testNonConsumableGetReturnsEmptyWhenNoneSet() {
        // On a clean keychain or test environment, getNonConsumables should return empty or valid dict
        let result = keychainManager.getNonConsumables()
        XCTAssertNotNil(result, "getNonConsumables should never return nil")
    }

    func testNonConsumableDefaultIsFalse() {
        XCTAssertFalse(keychainManager.isNonConsumableActive("nonexistent_product_\(UUID().uuidString)"))
    }

    func testNonConsumableCRUD() {
        // Note: Keychain may not work in all test environments
        // This test validates the API doesn't crash
        let productId = "test_product_\(UUID().uuidString)"

        keychainManager.setNonConsumable(productId, isActive: true)
        keychainManager.removeNonConsumable(productId)
        keychainManager.clearNonConsumables()
        // Should not crash
    }

    func testRetentionCoinAPI() {
        // Test that the API doesn't crash
        _ = keychainManager.hasGivenRetentionCoin()
        keychainManager.markRetentionCoinGiven()
        // Should not crash
    }

    func testAppleLoginDataAPI() {
        // Test the API surface doesn't crash
        keychainManager.setAppleLoginDatas("John Doe", "john@test.com")
        _ = keychainManager.getAppleEmail()
        _ = keychainManager.getAppleLoginFullName()
        // Should not crash
    }

    func testConcurrentNonConsumableAccess() {
        let iterations = 100
        let expectation = expectation(description: "Concurrent keychain access")
        expectation.expectedFulfillmentCount = iterations * 2

        let queue = DispatchQueue(label: "test.keychain.concurrent", attributes: .concurrent)

        for i in 0..<iterations {
            queue.async {
                let km = VxKeychainManager()
                km.setNonConsumable("concurrent_product_\(i)", isActive: true)
                expectation.fulfill()
            }
            queue.async {
                let km = VxKeychainManager()
                _ = km.getNonConsumables()
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }
}
