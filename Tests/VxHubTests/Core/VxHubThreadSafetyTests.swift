import XCTest
@testable import VxHub

final class VxHubThreadSafetyTests: XCTestCase {

    func testConcurrentIsPremiumReadWrite() {
        let hub = VxHub.shared
        let iterations = 1000
        let expectation = expectation(description: "Concurrent isPremium access")
        expectation.expectedFulfillmentCount = iterations * 2

        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)

        for i in 0..<iterations {
            queue.async {
                hub.isPremium = (i % 2 == 0)
                expectation.fulfill()
            }
            queue.async {
                _ = hub.isPremium
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testConcurrentBalanceReadWrite() {
        let hub = VxHub.shared
        let iterations = 1000
        let expectation = expectation(description: "Concurrent balance access")
        expectation.expectedFulfillmentCount = iterations * 2

        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)

        for i in 0..<iterations {
            queue.async {
                hub.balance = i
                expectation.fulfill()
            }
            queue.async {
                _ = hub.balance
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testConcurrentIsConnectedToInternetReadWrite() {
        let hub = VxHub.shared
        let iterations = 1000
        let expectation = expectation(description: "Concurrent isConnectedToInternet access")
        expectation.expectedFulfillmentCount = iterations * 2

        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)

        for i in 0..<iterations {
            queue.async {
                hub.isConnectedToInternet = (i % 2 == 0)
                expectation.fulfill()
            }
            queue.async {
                _ = hub.isConnectedToInternet
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testConcurrentRemoteConfigReadWrite() {
        let hub = VxHub.shared
        let iterations = 500
        let expectation = expectation(description: "Concurrent remoteConfig access")
        expectation.expectedFulfillmentCount = iterations * 2

        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)

        for i in 0..<iterations {
            queue.async {
                hub.remoteConfig = ["key\(i)": "value\(i)"]
                expectation.fulfill()
            }
            queue.async {
                _ = hub.remoteConfig
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }
}
