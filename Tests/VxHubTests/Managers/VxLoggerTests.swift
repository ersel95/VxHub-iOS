import XCTest
@testable import VxHub

final class VxLoggerTests: XCTestCase {

    func testLogLevelFiltering() {
        // Set to error level — lower levels should be filtered
        VxLogger.shared.setLogLevel(.error)

        // These should not crash even when filtered
        VxLogger.shared.verbose("verbose message")
        VxLogger.shared.debug("debug message")
        VxLogger.shared.info("info message")
        VxLogger.shared.warning("warning message")
        VxLogger.shared.error("error message")
        VxLogger.shared.success("success message")

        // Reset to verbose for other tests
        VxLogger.shared.setLogLevel(.verbose)
    }

    func testConcurrentLogging() {
        let iterations = 500
        let expectation = expectation(description: "Concurrent logging")
        expectation.expectedFulfillmentCount = iterations

        let queue = DispatchQueue(label: "test.logger.concurrent", attributes: .concurrent)

        for i in 0..<iterations {
            queue.async {
                VxLogger.shared.log("Concurrent message \(i)", level: .info, type: .info)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testLogLevelComparison() {
        XCTAssertTrue(LogLevel.verbose < LogLevel.debug)
        XCTAssertTrue(LogLevel.debug < LogLevel.info)
        XCTAssertTrue(LogLevel.info < LogLevel.warning)
        XCTAssertTrue(LogLevel.warning < LogLevel.error)
    }
}
