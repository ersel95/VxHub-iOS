import Foundation

// MARK: - Product Type (moved from VxRevenueCat)

public enum VxProductType: Int, Sendable {
    case consumable
    case nonConsumable
    case nonRenewalSubscription
    case renewalSubscription
}

// MARK: - Purchase Product Abstraction

public enum VxSubscriptionPeriodUnit: Int, Sendable {
    case day = 0
    case week = 1
    case month = 2
    case year = 3
}

public struct VxSubscriptionPeriod: Sendable {
    public let value: Int
    public let unit: VxSubscriptionPeriodUnit

    public init(value: Int, unit: VxSubscriptionPeriodUnit) {
        self.value = value
        self.unit = unit
    }
}

public enum VxPaymentMode: Int, Sendable {
    case payAsYouGo = 0
    case payUpFront = 1
    case freeTrial = 2
}

public struct VxProductDiscount: Sendable {
    public let paymentMode: VxPaymentMode
    public let subscriptionPeriod: VxSubscriptionPeriod
    public let hasSK1Discount: Bool

    public init(paymentMode: VxPaymentMode, subscriptionPeriod: VxSubscriptionPeriod, hasSK1Discount: Bool) {
        self.paymentMode = paymentMode
        self.subscriptionPeriod = subscriptionPeriod
        self.hasSK1Discount = hasSK1Discount
    }
}

public enum VxStoreProductType: Int, Sendable {
    case consumable = 0
    case nonConsumable = 1
    case nonRenewableSubscription = 2
    case autoRenewableSubscription = 3
}

public protocol VxPurchaseProduct: Sendable {
    var productIdentifier: String { get }
    var productType: VxStoreProductType { get }
    var price: Decimal { get }
    var localizedTitle: String { get }
    var localizedDescription: String { get }
    var localizedPriceString: String { get }
    var localizedPricePerWeek: String? { get }
    var localizedPricePerMonth: String? { get }
    var priceLocale: Locale { get }
    var subscriptionPeriod: VxSubscriptionPeriod? { get }
    var introductoryDiscount: VxProductDiscount? { get }
}

// MARK: - Transaction & Customer Info Abstractions

public protocol VxPurchaseTransaction: Sendable {
    var transactionIdentifier: String? { get }
    var productIdentifier: String? { get }
}

public protocol VxPurchaseCustomerInfo: Sendable {
    var activeSubscriptions: Set<String> { get }
    var nonSubscriptionProductIdentifiers: [String] { get }
}

// MARK: - VxStoreProduct (moved from VxRevenueCat)

public struct VxStoreProduct: Sendable {
    public let storeProduct: any VxPurchaseProduct
    public let isDiscountOrTrialEligible: Bool
    public let initialBonus: Int?
    public let renewalBonus: Int?
    public let vxProductType: VxProductType?

    public init(
        storeProduct: any VxPurchaseProduct,
        isDiscountOrTrialEligible: Bool,
        initialBonus: Int?,
        renewalBonus: Int?,
        vxProductType: VxProductType?
    ) {
        self.storeProduct = storeProduct
        self.isDiscountOrTrialEligible = isDiscountOrTrialEligible
        self.initialBonus = initialBonus
        self.renewalBonus = renewalBonus
        self.vxProductType = vxProductType
    }
}

// MARK: - Purchase Provider Protocol

public protocol VxPurchaseProvider: Sendable {
    var isConfigured: Bool { get }

    func configure(apiKey: String, appUserID: String)
    func setLogLevel(_ level: VxPurchaseLogLevel)

    func purchase(_ product: any VxPurchaseProduct, completion: @escaping @Sendable (Bool, (any VxPurchaseTransaction)?) -> Void)
    func restorePurchases(completion: @escaping @Sendable (Bool, Bool, String?) -> Void)
    func requestProducts(completion: @escaping @Sendable ([any VxPurchaseProduct]) -> Void)
    func getCustomerInfo(completion: @escaping @Sendable ((any VxPurchaseCustomerInfo)?, Error?) -> Void)
    func checkTrialOrIntroDiscountEligibility(product: any VxPurchaseProduct, completion: @escaping @Sendable (Bool) -> Void)
    func syncAttributesAndOfferingsIfNeeded(completion: @escaping @Sendable () -> Void)

    func setOnesignalID(_ id: String)
    func setFBAnonymousID(_ id: String)
    func setAppsflyerID(_ id: String)
    func setFirebaseAppInstanceID(_ id: String)
    func setAttributes(_ attributes: [String: String])
    func setEmail(_ email: String?)
    func setDisplayName(_ name: String?)
    func collectDeviceIdentifiers()

    func logOut(completion: @escaping @Sendable (Error?) -> Void)
    func logIn(_ appUserID: String, completion: @escaping @Sendable ((any VxPurchaseCustomerInfo)?, Bool, Error?) -> Void)
    func syncPurchases(completion: @escaping @Sendable ((any VxPurchaseCustomerInfo)?, Error?) -> Void)

    func validatePurchase(transactionId: String)
}

public enum VxPurchaseLogLevel: Sendable {
    case debug, info, warn, error
}
