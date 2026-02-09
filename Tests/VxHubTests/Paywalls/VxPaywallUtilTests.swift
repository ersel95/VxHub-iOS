#if canImport(UIKit)
import XCTest
@testable import VxHub

final class VxPaywallUtilTests: XCTestCase {

    func testRevenueCatProductTypeRawValues() {
        XCTAssertEqual(RevenueCatProductType.consumable.rawValue, 0)
        XCTAssertEqual(RevenueCatProductType.nonConsumable.rawValue, 1)
        XCTAssertEqual(RevenueCatProductType.nonRenewableSubscription.rawValue, 2)
        XCTAssertEqual(RevenueCatProductType.autoRenewableSubscription.rawValue, 3)
    }

    func testRevenueCatProductTypeFromRawValue() {
        XCTAssertEqual(RevenueCatProductType(rawValue: 0), .consumable)
        XCTAssertEqual(RevenueCatProductType(rawValue: 1), .nonConsumable)
        XCTAssertEqual(RevenueCatProductType(rawValue: 2), .nonRenewableSubscription)
        XCTAssertEqual(RevenueCatProductType(rawValue: 3), .autoRenewableSubscription)
        XCTAssertNil(RevenueCatProductType(rawValue: 99), "Invalid raw value should return nil")
    }

    func testSubPeriodRawValues() {
        XCTAssertEqual(SubPreiod.day.rawValue, 0)
        XCTAssertEqual(SubPreiod.week.rawValue, 1)
        XCTAssertEqual(SubPreiod.month.rawValue, 2)
        XCTAssertEqual(SubPreiod.year.rawValue, 3)
    }

    func testSubPeriodFromRawValue() {
        XCTAssertEqual(SubPreiod(rawValue: 0), .day)
        XCTAssertEqual(SubPreiod(rawValue: 1), .week)
        XCTAssertEqual(SubPreiod(rawValue: 2), .month)
        XCTAssertEqual(SubPreiod(rawValue: 3), .year)
        XCTAssertNil(SubPreiod(rawValue: 99))
    }

    func testSubDataCodable() throws {
        let subData = SubData(
            id: 1,
            identifier: "com.test.yearly",
            title: "Yearly",
            description: "Yearly subscription",
            localizedPrice: "$49.99",
            weeklyPrice: "$0.96",
            monthlyPrice: "$4.17",
            dailyPrice: "$0.14",
            subPeriod: .year,
            freeTrialPeriod: .week,
            freeTrialUnit: 7,
            initiallySelected: true,
            discountAmount: 50,
            eligibleForFreeTrialOrDiscount: true,
            isBestOffer: true,
            initial_bonus: 100,
            renewal_bonus: 50,
            productType: .autoRenewableSubscription,
            nonDiscountedPrice: "$99.99",
            price: Decimal(49.99)
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(subData)
        XCTAssertFalse(data.isEmpty)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SubData.self, from: data)
        XCTAssertEqual(decoded.identifier, "com.test.yearly")
        XCTAssertEqual(decoded.subPeriod, .year)
        XCTAssertEqual(decoded.productType, .autoRenewableSubscription)
    }

    func testExperimentPayloadDecoding() throws {
        let json = """
        {
            "product": "com.test.weekly",
            "non_discounted_product_id": "com.test.monthly",
            "products": ["com.test.weekly", "com.test.yearly"],
            "selectedIndex": 0
        }
        """.data(using: .utf8)!

        let payload = try JSONDecoder().decode(ExperimentPayload.self, from: json)
        XCTAssertEqual(payload.product, "com.test.weekly")
        XCTAssertEqual(payload.nonDiscountedProductId, "com.test.monthly")
        XCTAssertEqual(payload.products?.count, 2)
        XCTAssertEqual(payload.selectedIndex, 0)
    }

    func testExperimentPayloadPartialDecoding() throws {
        let json = """
        {
            "product": "com.test.weekly"
        }
        """.data(using: .utf8)!

        let payload = try JSONDecoder().decode(ExperimentPayload.self, from: json)
        XCTAssertEqual(payload.product, "com.test.weekly")
        XCTAssertNil(payload.nonDiscountedProductId)
        XCTAssertNil(payload.products)
        XCTAssertNil(payload.selectedIndex)
    }
}
#endif
