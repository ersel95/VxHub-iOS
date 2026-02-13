//
//  VxRevenueCatProvider.swift
//  VxHub
//
//  Created by VxHub on 2025.
//

import Foundation
import VxHubCore
import RevenueCat

// MARK: - StoreProduct -> VxPurchaseProduct Wrapper

public struct RevenueCatProductAdapter: VxPurchaseProduct, @unchecked Sendable {
    public let rcProduct: StoreProduct

    public init(_ product: StoreProduct) {
        self.rcProduct = product
    }

    public var productIdentifier: String { rcProduct.productIdentifier }

    public var productType: VxStoreProductType {
        switch rcProduct.productCategory {
        case .subscription:
            return .autoRenewableSubscription
        case .nonSubscription:
            return .consumable
        }
    }

    public var price: Decimal { rcProduct.price }
    public var localizedTitle: String { rcProduct.localizedTitle }
    public var localizedDescription: String { rcProduct.localizedDescription }
    public var localizedPriceString: String { rcProduct.localizedPriceString }

    public var localizedPricePerWeek: String? {
        guard let period = rcProduct.subscriptionPeriod else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = rcProduct.priceFormatter?.locale ?? .current

        let pricePerDay: Decimal
        switch period.unit {
        case .day:    pricePerDay = rcProduct.price / Decimal(period.value)
        case .week:   pricePerDay = rcProduct.price / Decimal(period.value * 7)
        case .month:  pricePerDay = rcProduct.price / Decimal(period.value * 30)
        case .year:   pricePerDay = rcProduct.price / Decimal(period.value * 365)
        @unknown default: return nil
        }
        return formatter.string(from: (pricePerDay * 7) as NSDecimalNumber)
    }

    public var localizedPricePerMonth: String? {
        guard let period = rcProduct.subscriptionPeriod else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = rcProduct.priceFormatter?.locale ?? .current

        let pricePerDay: Decimal
        switch period.unit {
        case .day:    pricePerDay = rcProduct.price / Decimal(period.value)
        case .week:   pricePerDay = rcProduct.price / Decimal(period.value * 7)
        case .month:  pricePerDay = rcProduct.price / Decimal(period.value * 30)
        case .year:   pricePerDay = rcProduct.price / Decimal(period.value * 365)
        @unknown default: return nil
        }
        return formatter.string(from: (pricePerDay * 30) as NSDecimalNumber)
    }

    public var priceLocale: Locale {
        return rcProduct.priceFormatter?.locale ?? .current
    }

    public var subscriptionPeriod: VxSubscriptionPeriod? {
        guard let rcPeriod = rcProduct.subscriptionPeriod else { return nil }
        let unit: VxSubscriptionPeriodUnit
        switch rcPeriod.unit {
        case .day:    unit = .day
        case .week:   unit = .week
        case .month:  unit = .month
        case .year:   unit = .year
        @unknown default: unit = .month
        }
        return VxSubscriptionPeriod(value: rcPeriod.value, unit: unit)
    }

    public var introductoryDiscount: VxProductDiscount? {
        guard let rcDiscount = rcProduct.introductoryDiscount else { return nil }
        let paymentMode: VxPaymentMode
        switch rcDiscount.paymentMode {
        case .payAsYouGo: paymentMode = .payAsYouGo
        case .payUpFront:  paymentMode = .payUpFront
        case .freeTrial:   paymentMode = .freeTrial
        @unknown default:  paymentMode = .payAsYouGo
        }

        let periodUnit: VxSubscriptionPeriodUnit
        switch rcDiscount.subscriptionPeriod.unit {
        case .day:    periodUnit = .day
        case .week:   periodUnit = .week
        case .month:  periodUnit = .month
        case .year:   periodUnit = .year
        @unknown default: periodUnit = .month
        }

        let period = VxSubscriptionPeriod(value: rcDiscount.subscriptionPeriod.value, unit: periodUnit)
        return VxProductDiscount(
            paymentMode: paymentMode,
            subscriptionPeriod: period,
            hasSK1Discount: rcDiscount.sk1Discount != nil
        )
    }
}

// MARK: - StoreTransaction -> VxPurchaseTransaction Wrapper

public struct RevenueCatTransactionAdapter: VxPurchaseTransaction, Sendable {
    private let rcTransaction: StoreTransaction

    public init(_ transaction: StoreTransaction) {
        self.rcTransaction = transaction
    }

    public var transactionIdentifier: String? { rcTransaction.transactionIdentifier }
    public var productIdentifier: String? { rcTransaction.productIdentifier }
}

// MARK: - CustomerInfo -> VxPurchaseCustomerInfo Wrapper

public struct RevenueCatCustomerInfoAdapter: VxPurchaseCustomerInfo, Sendable {
    private let rcInfo: CustomerInfo

    public init(_ info: CustomerInfo) {
        self.rcInfo = info
    }

    public var activeSubscriptions: Set<String> { rcInfo.activeSubscriptions }
    public var nonSubscriptionProductIdentifiers: [String] {
        return rcInfo.nonSubscriptions.map { $0.productIdentifier }
    }
}

// MARK: - VxRevenueCatProvider

public final class VxRevenueCatProvider: VxPurchaseProvider, @unchecked Sendable {

    public init() {}

    public var isConfigured: Bool {
        return Purchases.isConfigured
    }

    public func configure(apiKey: String, appUserID: String) {
        Purchases.configure(withAPIKey: apiKey, appUserID: appUserID)
    }

    public func setLogLevel(_ level: VxPurchaseLogLevel) {
        switch level {
        case .debug: Purchases.logLevel = .debug
        case .info:  Purchases.logLevel = .info
        case .warn:  Purchases.logLevel = .warn
        case .error: Purchases.logLevel = .error
        }
    }

    public func purchase(_ product: any VxPurchaseProduct, completion: @escaping @Sendable (Bool, (any VxPurchaseTransaction)?) -> Void) {
        guard Purchases.isConfigured else {
            completion(false, nil)
            return
        }
        let rcProduct: StoreProduct
        if let adapter = product as? RevenueCatProductAdapter {
            rcProduct = adapter.rcProduct
        } else {
            completion(false, nil)
            return
        }
        Purchases.shared.purchase(product: rcProduct) { transaction, customerInfo, error, userCancelled in
            if error != nil || userCancelled {
                let adapted = transaction.map { RevenueCatTransactionAdapter($0) }
                completion(false, adapted)
                return
            }
            if let tx = transaction, tx.transactionIdentifier.isEmpty == false {
                completion(true, RevenueCatTransactionAdapter(tx))
            } else {
                let adapted = transaction.map { RevenueCatTransactionAdapter($0) }
                completion(false, adapted)
            }
        }
    }

    public func restorePurchases(completion: @escaping @Sendable (Bool, Bool, String?) -> Void) {
        guard Purchases.isConfigured else {
            completion(false, false, "RevenueCat is not configured")
            return
        }
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                completion(false, false, error.localizedDescription)
                return
            }
            guard let customerInfo = customerInfo else {
                completion(false, false, "Could not get CustomerInfo")
                return
            }
            let hasActiveSubscription = !customerInfo.activeSubscriptions.isEmpty
            let hasActiveNonConsumable = !customerInfo.nonSubscriptions.isEmpty
            completion(hasActiveSubscription, hasActiveNonConsumable, nil)
        }
    }

    public func requestProducts(completion: @escaping @Sendable ([any VxPurchaseProduct]) -> Void) {
        guard Purchases.isConfigured else {
            completion([])
            return
        }
        Purchases.shared.getOfferings { offerings, error in
            if error != nil {
                completion([])
                return
            }
            guard let offerings = offerings else {
                completion([])
                return
            }
            let products = offerings.current?.availablePackages.map { RevenueCatProductAdapter($0.storeProduct) } ?? []
            completion(products)
        }
    }

    public func getCustomerInfo(completion: @escaping @Sendable ((any VxPurchaseCustomerInfo)?, Error?) -> Void) {
        guard Purchases.isConfigured else {
            completion(nil, NSError(domain: "VxRevenueCatProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "RevenueCat is not configured"]))
            return
        }
        Purchases.shared.getCustomerInfo { customerInfo, error in
            let adapted = customerInfo.map { RevenueCatCustomerInfoAdapter($0) }
            completion(adapted, error)
        }
    }

    public func checkTrialOrIntroDiscountEligibility(product: any VxPurchaseProduct, completion: @escaping @Sendable (Bool) -> Void) {
        guard Purchases.isConfigured else {
            completion(false)
            return
        }
        Purchases.shared.checkTrialOrIntroDiscountEligibility(productIdentifiers: [product.productIdentifier]) { eligibilityMap in
            let isEligible = eligibilityMap[product.productIdentifier]?.status == .eligible
            completion(isEligible)
        }
    }

    public func syncAttributesAndOfferingsIfNeeded(completion: @escaping @Sendable () -> Void) {
        guard Purchases.isConfigured else {
            completion()
            return
        }
        Purchases.shared.syncAttributesAndOfferingsIfNeeded { _, _ in
            completion()
        }
    }

    // MARK: - Attributes

    public func setOnesignalID(_ id: String) {
        guard Purchases.isConfigured else { return }
        Purchases.shared.attribution.setOnesignalID(id)
    }

    public func setFBAnonymousID(_ id: String) {
        guard Purchases.isConfigured else { return }
        Purchases.shared.attribution.setFBAnonymousID(id)
    }

    public func setAppsflyerID(_ id: String) {
        guard Purchases.isConfigured else { return }
        Purchases.shared.attribution.setAppsflyerID(id)
    }

    public func setFirebaseAppInstanceID(_ id: String) {
        guard Purchases.isConfigured else { return }
        Purchases.shared.attribution.setFirebaseAppInstanceID(id)
    }

    public func setAttributes(_ attributes: [String: String]) {
        guard Purchases.isConfigured else { return }
        Purchases.shared.attribution.setAttributes(attributes)
    }

    public func setEmail(_ email: String?) {
        guard Purchases.isConfigured else { return }
        Purchases.shared.attribution.setEmail(email)
    }

    public func setDisplayName(_ name: String?) {
        guard Purchases.isConfigured else { return }
        Purchases.shared.attribution.setDisplayName(name)
    }

    public func collectDeviceIdentifiers() {
        guard Purchases.isConfigured else { return }
        Purchases.shared.attribution.collectDeviceIdentifiers()
    }

    // MARK: - Identity

    public func logOut(completion: @escaping @Sendable (Error?) -> Void) {
        guard Purchases.isConfigured else {
            completion(nil)
            return
        }
        Purchases.shared.logOut { _, error in
            completion(error)
        }
    }

    public func logIn(_ appUserID: String, completion: @escaping @Sendable ((any VxPurchaseCustomerInfo)?, Bool, Error?) -> Void) {
        guard Purchases.isConfigured else {
            completion(nil, false, NSError(domain: "VxRevenueCatProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "RevenueCat is not configured"]))
            return
        }
        Purchases.shared.logIn(appUserID) { customerInfo, created, error in
            let adapted = customerInfo.map { RevenueCatCustomerInfoAdapter($0) }
            completion(adapted, created, error)
        }
    }

    public func syncPurchases(completion: @escaping @Sendable ((any VxPurchaseCustomerInfo)?, Error?) -> Void) {
        guard Purchases.isConfigured else {
            completion(nil, nil)
            return
        }
        Purchases.shared.syncPurchases { customerInfo, error in
            let adapted = customerInfo.map { RevenueCatCustomerInfoAdapter($0) }
            completion(adapted, error)
        }
    }

    // MARK: - Validation

    public func validatePurchase(transactionId: String) {
        let networkManager = VxNetworkManager()
        networkManager.validatePurchase(transactionId: transactionId)
    }
}
