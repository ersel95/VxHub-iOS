import XCTest
@testable import VxHub

final class VxEndPointTests: XCTestCase {

    func testAppStoreVersionBaseURL() {
        let endpoint = VxHubApi.getAppStoreVersion
        let baseURLString = endpoint.baseURLString
        XCTAssertTrue(baseURLString.contains("itunes.apple.com"), "App Store endpoint should use iTunes URL")
    }

    func testPathGeneration() {
        XCTAssertEqual(VxHubApi.deviceRegister.path, "device/register")
        XCTAssertEqual(VxHubApi.getProducts.path, "product/app")
        XCTAssertEqual(VxHubApi.getTickets.path, "support/tickets")
        XCTAssertEqual(VxHubApi.getTicketsUnseenStatus.path, "support/unseen")
        XCTAssertEqual(VxHubApi.deleteDevice.path, "device")
        XCTAssertEqual(VxHubApi.claimRetentionCoin.path, "device/retention/claim")
        XCTAssertEqual(VxHubApi.getAppStoreVersion.path, "")
    }

    func testTicketMessagePathContainsTicketId() {
        let ticketId = "abc123"
        let endpoint = VxHubApi.getTicketMessages(ticketId: ticketId)
        XCTAssertEqual(endpoint.path, "support/tickets/\(ticketId)")
    }

    func testCreateNewMessagePathContainsTicketId() {
        let ticketId = "xyz456"
        let endpoint = VxHubApi.createNewMessage(ticketId: ticketId, message: "hello")
        XCTAssertEqual(endpoint.path, "support/tickets/\(ticketId)/messages")
    }

    func testHTTPMethods() {
        // POST endpoints
        XCTAssertEqual(VxHubApi.deviceRegister.httpMethod, .post)
        XCTAssertEqual(VxHubApi.validatePurchase(transactionId: "t1").httpMethod, .post)
        XCTAssertEqual(VxHubApi.usePromoCode(promoCode: "pc").httpMethod, .post)
        XCTAssertEqual(VxHubApi.createNewTicket(category: "c", message: "m").httpMethod, .post)
        XCTAssertEqual(VxHubApi.claimRetentionCoin.httpMethod, .post)

        // GET endpoints
        XCTAssertEqual(VxHubApi.getProducts.httpMethod, .get)
        XCTAssertEqual(VxHubApi.getTickets.httpMethod, .get)
        XCTAssertEqual(VxHubApi.getAppStoreVersion.httpMethod, .get)

        // DELETE endpoints
        XCTAssertEqual(VxHubApi.deleteDevice.httpMethod, .delete)
    }

    func testAppStoreVersionHeadersAreNil() {
        let endpoint = VxHubApi.getAppStoreVersion
        XCTAssertNil(endpoint.headers, "App Store version endpoint should not have custom headers")
    }

    func testHeadersContainHubIdWhenConfigExists() {
        // When deviceConfig is nil, headers should gracefully handle it
        let endpoint = VxHubApi.getProducts
        let headers = endpoint.headers
        // Should not crash — deviceConfig may be nil
        if let headers = headers {
            XCTAssertNotNil(headers["X-Hub-Id"])
            XCTAssertNotNil(headers["X-Hub-Device-Id"])
        }
    }
}
