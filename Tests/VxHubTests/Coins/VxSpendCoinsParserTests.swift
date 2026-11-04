import XCTest
@testable import VxHubCore

/// The parser mirrors the backend contract in volvoxhub src/coins (POST device/balance/spend).
final class VxSpendCoinsParserTests: XCTestCase {

    private func data(_ json: String) -> Data { json.data(using: .utf8)! }

    func testSpentReportsTheRemainingBalance() {
        let result = VxSpendCoinsParser.parse(statusCode: 200, data: data(
            #"{"status":"spent","balance":2,"premium":false,"charged":1,"transaction_id":42}"#))
        XCTAssertEqual(result, .spent(balance: 2))
    }

    func testPremiumIsNeverACharge() {
        let result = VxSpendCoinsParser.parse(statusCode: 200, data: data(
            #"{"status":"premium","balance":3,"premium":true,"charged":0,"transaction_id":null}"#))
        XCTAssertEqual(result, .premium(balance: 3))
    }

    func testInsufficientCreditsCarriesTheBalance() {
        let result = VxSpendCoinsParser.parse(statusCode: 403, data: data(
            #"{"errorMessage":"Insufficient balance","errorCode":"INSUFFICIENT_CREDITS","balance":0}"#))
        XCTAssertEqual(result, .insufficient(balance: 0))
        XCTAssertEqual(result.balance, 0)
    }

    func testOtherFailuresAreNotInsufficient() {
        XCTAssertEqual(VxSpendCoinsParser.parse(statusCode: 403, data: data(#"{"message":"Device does not belong to this app"}"#)),
                       .failed("Spend failed (403)"))
        XCTAssertEqual(VxSpendCoinsParser.parse(statusCode: 500, data: Data()), .failed("Spend failed (500)"))
        XCTAssertNil(VxSpendCoinsParser.parse(statusCode: 404, data: Data()).balance)
    }

    func testUnreadableSuccessBodyIsAFailure() {
        XCTAssertEqual(VxSpendCoinsParser.parse(statusCode: 200, data: data("{}")), .failed("Unreadable spend response"))
    }
}
