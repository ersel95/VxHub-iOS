import XCTest
@testable import VxHub

final class RouterTests: XCTestCase {

    func testRouterBuildRequestSetsHTTPMethod() throws {
        let router = Router<VxHubApi>()
        // Use getAppStoreVersion since it doesn't need config
        let request = try router.buildRequest(from: .getAppStoreVersion)
        XCTAssertEqual(request.httpMethod, "GET")
    }

    func testRouterBuildRequestSetsURL() throws {
        let router = Router<VxHubApi>()
        let request = try router.buildRequest(from: .getAppStoreVersion)
        let urlString = request.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("itunes.apple.com"), "Request URL should contain itunes.apple.com")
    }

    func testRouterBuildRequestTimeoutInterval() throws {
        let router = Router<VxHubApi>()
        let request = try router.buildRequest(from: .getAppStoreVersion)
        XCTAssertEqual(request.timeoutInterval, 10.0)
    }

    func testRouterBuildRequestCachePolicy() throws {
        let router = Router<VxHubApi>()
        let request = try router.buildRequest(from: .getAppStoreVersion)
        XCTAssertEqual(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }

    func testRouterCancelDoesNotCrash() {
        let router = Router<VxHubApi>()
        // Cancel without any active task should not crash
        router.cancel()
    }
}
