import XCTest
@testable import VxHub
@testable import VxHubCore

final class VxVerificationOutcomeTests: XCTestCase {

    private func body(premium: Bool, balance: Int = 3) -> Data {
        """
        {"status":"success","vid":"d7a92324-6136-4783-9f34-2def69d02543","verified":true,
         "device":{"premium_status":\(premium),"balance":\(balance)}}
        """.data(using: .utf8)!
    }

    func testSuccessBodyIsVerifiedWithBackendPremiumAndBalance() {
        XCTAssertEqual(VxVerificationOutcome.classify(statusCode: 200, data: body(premium: true, balance: 7), transportError: nil),
                       .verified(isPremium: true, balance: 7))
        XCTAssertEqual(VxVerificationOutcome.classify(statusCode: 201, data: body(premium: false), transportError: nil),
                       .verified(isPremium: false, balance: 3))
    }

    func testBodyWithoutVerifiedFieldStillDecodes() {
        // Production's current after-purchase response has no `verified` key.
        let legacy = #"{"status":"success","vid":"x","device":{"premium_status":true,"balance":0}}"#.data(using: .utf8)!
        XCTAssertEqual(VxVerificationOutcome.classify(statusCode: 200, data: legacy, transportError: nil),
                       .verified(isPremium: true, balance: 0))
    }

    func testTimeoutAndServerErrorsAreRetriedLater() {
        if case .retryLater = VxVerificationOutcome.classify(statusCode: nil, data: nil, transportError: URLError(.timedOut)) {} else {
            XCTFail("A timeout must keep the transaction queued")
        }
        for code in [408, 429, 500, 502, 503] {
            if case .retryLater = VxVerificationOutcome.classify(statusCode: code, data: nil, transportError: nil) {} else {
                XCTFail("\(code) must be retried later")
            }
        }
    }

    func testUndecodableSuccessIsNotTreatedAsVerified() {
        let garbage = "<html>".data(using: .utf8)
        if case .retryLater = VxVerificationOutcome.classify(statusCode: 200, data: garbage, transportError: nil) {} else {
            XCTFail("An unreadable 200 must not unlock or drop anything")
        }
    }

    func testMissingEndpointAndClientErrors() {
        XCTAssertEqual(VxVerificationOutcome.classify(statusCode: 404, data: nil, transportError: nil), .unsupported)
        XCTAssertEqual(VxVerificationOutcome.classify(statusCode: 400, data: nil, transportError: nil), .rejected(statusCode: 400))
        XCTAssertEqual(VxVerificationOutcome.classify(statusCode: 401, data: nil, transportError: nil), .rejected(statusCode: 401))
    }
}

final class VxPendingPurchaseStoreTests: XCTestCase {

    private var defaults: UserDefaults!
    private let suite = "VxPendingPurchaseStoreTests"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suite)
        defaults.removePersistentDomain(forName: suite)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suite)
        super.tearDown()
    }

    func testAddedTransactionSurvivesANewStoreInstance() {
        VxPendingPurchaseStore(defaults: defaults).add(transactionId: "t1", productId: "lifetime")
        let reloaded = VxPendingPurchaseStore(defaults: defaults).all
        XCTAssertEqual(reloaded.map(\.transactionId), ["t1"])
        XCTAssertEqual(reloaded.first?.productId, "lifetime")
        XCTAssertEqual(reloaded.first?.attempts, 0)
    }

    func testSameTransactionIsNotQueuedTwice() {
        let store = VxPendingPurchaseStore(defaults: defaults)
        store.add(transactionId: "t1", productId: "p")
        store.add(transactionId: "t1", productId: "p")
        XCTAssertEqual(store.all.count, 1)
    }

    func testRemoveOnlyDropsThatTransaction() {
        let store = VxPendingPurchaseStore(defaults: defaults)
        store.add(transactionId: "t1", productId: "p")
        store.add(transactionId: "t2", productId: "p")
        store.remove(transactionId: "t1")
        XCTAssertEqual(store.all.map(\.transactionId), ["t2"])
    }

    func testFailedAttemptsAreCountedAndCapped() {
        let store = VxPendingPurchaseStore(defaults: defaults)
        store.add(transactionId: "t1", productId: "p")
        for _ in 1..<VxPendingPurchaseStore.maxAttempts {
            XCTAssertTrue(store.recordFailedAttempt(transactionId: "t1"))
        }
        XCTAssertEqual(store.all.first?.attempts, VxPendingPurchaseStore.maxAttempts - 1)
        XCTAssertFalse(store.recordFailedAttempt(transactionId: "t1"), "The last allowed attempt drops the entry")
        XCTAssertTrue(store.all.isEmpty)
    }

    func testEntriesOlderThanMaxAgeAreDropped() {
        let store = VxPendingPurchaseStore(defaults: defaults)
        let created = Date(timeIntervalSince1970: 0)
        store.add(transactionId: "old", productId: "p", now: created)
        let later = created.addingTimeInterval(VxPendingPurchaseStore.maxAge + 1)
        XCTAssertFalse(store.recordFailedAttempt(transactionId: "old", now: later))
        XCTAssertTrue(store.all.isEmpty)
    }

    func testRetryPassesAreCoalesced() {
        let store = VxPendingPurchaseStore(defaults: defaults)
        XCTAssertTrue(store.beginRetryPass())
        XCTAssertFalse(store.beginRetryPass())
        store.endRetryPass()
        XCTAssertTrue(store.beginRetryPass())
        store.endRetryPass()
    }
}

final class VxPurchaseEndpointTests: XCTestCase {

    func testAfterPurchaseEndpoint() throws {
        let endpoint = VxHubApi.afterPurchaseCheck(transactionId: "2000001", productId: "com.app.pro.lifetime")
        XCTAssertEqual(endpoint.path, "device/after-purchase")
        XCTAssertEqual(endpoint.httpMethod, .post)
        let request = try Router<VxHubApi>().buildRequest(from: endpoint)
        let json = try XCTUnwrap(request.httpBody.flatMap { try JSONSerialization.jsonObject(with: $0) as? [String: String] })
        XCTAssertEqual(json["transaction_id"], "2000001")
        XCTAssertEqual(json["product_id"], "com.app.pro.lifetime")
    }

    func testRestoreVerificationEndpoint() {
        XCTAssertEqual(VxHubApi.restoreVerification.path, "device/restore")
        XCTAssertEqual(VxHubApi.restoreVerification.httpMethod, .post)
    }
}

final class VxSessionTrackerVersionTests: XCTestCase {

    func testSessionAppVersionIsNotTheOSVersion() {
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        XCTAssertEqual(VxSessionTracker.appVersion, bundleVersion)
    }
}
