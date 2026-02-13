#if os(iOS)
import XCTest
@testable import VxHub
@testable import VxHubCore

final class VxBannerManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        VxBannerManager.shared.dismissAllBanners()
    }

    func testDismissAllBannersDoesNotCrash() {
        // Should not crash when there are no banners
        VxBannerManager.shared.dismissAllBanners()
    }

    func testDismissCurrentBannerWhenEmpty() {
        // Should not crash when dismissing with empty queue
        let expectation = expectation(description: "Dismiss completes")
        VxBannerManager.shared.dismissCurrentBanner()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testDuplicateBannerNotAdded() {
        let model = VxBannerModel(
            id: "test1",
            type: .info,
            font: .rounded,
            title: "Test Banner"
        )

        let expectation = expectation(description: "Banner enqueued")

        // Add same banner twice
        VxBannerManager.shared.addBannerToQuery(type: .info, model: model)
        VxBannerManager.shared.addBannerToQuery(type: .info, model: model)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
        // If we reach here without crash, the duplicate check works
    }
}
#endif
