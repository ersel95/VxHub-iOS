//
//  File.swift
//  VxHub
//
//  Created by furkan on 11.11.2024.
//

import Foundation
import VxHubCore
import RevenueCat

internal protocol VxRevenueCatDelegate: AnyObject {
    func didPurchaseComplete(didSucceed: Bool, error: String?)
    func didRestorePurchases(didSucceed: Bool, error: String?)
    func didFetchProducts(products: [StoreProduct]?, error: String?)
}

// VxProductType - REMOVED, now in VxHubCore
// VxStoreProduct - REMOVED, now in VxHubCore

internal final class VxRevenueCat: @unchecked Sendable {
    public init() {}

    public var products : [VxStoreProduct] {
        guard Purchases.isConfigured else {
            VxLogger.shared.error("Error initializing purchases")
            return []
        }

        return VxHub.shared.revenueCatProducts
    }

    //hasActiveSubscription, hasActiveNonConsumable, hasError
    internal func restorePurchases(completion: (@Sendable (Bool, Bool, String?) -> Void)? = nil) {
        guard Purchases.isConfigured else {
            VxLogger.shared.error("Error initializing purchases")
            completion?(false, false, "RevenueCat is not configured")
            return
        }
        Purchases.shared.restorePurchases { customerInfo, error in
            VxHub.shared.start { _ in
                if let error = error {
                    VxLogger.shared.error("Error restoring purchases: \(error)")
                    completion?(false, false, error.localizedDescription)
                    return
                }

                guard let customerInfo else {
                    completion?(false, false, "Could Not Get CustomerInfo")
                    return
                }

                let hasActiveSubscription = VxHub.shared.isPremium
                let hasActiveNonConsumable = customerInfo.nonSubscriptions
                completion?(hasActiveSubscription, hasActiveNonConsumable.isEmpty, nil)
            }
        }
    }


    public func purchase(_ productToBuy: StoreProduct, completion: (@Sendable (Bool, StoreTransaction?) -> Void)? = nil) {
        guard Purchases.isConfigured else {
            VxLogger.shared.error("Error initializing purchases")
            completion?(false, nil)
            return
        }
        Purchases.shared.purchase(product: productToBuy) { transaction, customerInfo, error, userCancelled in
            if let error {
                VxLogger.shared.error("Error purchasing product: \(error)")
                completion?(false, transaction)
                return
            }

            if userCancelled {
                completion?(false, transaction)
            } else {
                if transaction?.transactionIdentifier != nil {
                    let networkManager = VxNetworkManager()
                    networkManager.validatePurchase(transactionId: transaction?.transactionIdentifier ?? "COULD_NOT_FIND_TRANSACTION_ID")
                    VxLogger.shared.success("Purchase completed with transaction")
                    completion?(true, transaction)
                } else {
                    VxLogger.shared.warning("Purchase completed without transaction identifier")
                    completion?(false, transaction)
                }
            }
        }
    }

    internal func requestRevenueCatProducts(completion: (([StoreProduct]) -> Void)? = nil) {
        guard Purchases.isConfigured else {
            VxLogger.shared.error("Error initializing purchases")
            completion?([])
            return
        }

        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                VxLogger.shared.error("Error fetching offerings: \(error)")
                completion?([])
                return
            }
            guard let offerings = offerings else {
                completion?([])
                return }
            let products = offerings.current?.availablePackages.map({ $0.storeProduct })
            completion?(products ?? [])
        }
    }

    // MARK: - Async Methods

    internal func requestRevenueCatProducts() async throws -> [StoreProduct] {
        guard Purchases.isConfigured else {
            VxLogger.shared.error("Error initializing purchases")
            throw VxHubError.unknown("RevenueCat is not configured")
        }

        let offerings = try await Purchases.shared.offerings()
        return offerings.current?.availablePackages.map({ $0.storeProduct }) ?? []
    }

    public func purchase(_ productToBuy: StoreProduct) async throws -> (success: Bool, transaction: StoreTransaction?) {
        guard Purchases.isConfigured else {
            VxLogger.shared.error("Error initializing purchases")
            throw VxHubError.unknown("RevenueCat is not configured")
        }
        return try await withCheckedThrowingContinuation { continuation in
            purchase(productToBuy) { success, transaction in
                continuation.resume(returning: (success, transaction))
            }
        }
    }

    internal func restorePurchases() async throws -> (hasActiveSubscription: Bool, hasActiveNonConsumable: Bool, error: String?) {
        guard Purchases.isConfigured else {
            VxLogger.shared.error("Error initializing purchases")
            throw VxHubError.unknown("RevenueCat is not configured")
        }
        return try await withCheckedThrowingContinuation { continuation in
            restorePurchases { hasActiveSubscription, hasActiveNonConsumable, error in
                continuation.resume(returning: (hasActiveSubscription, hasActiveNonConsumable, error))
            }
        }
    }
}
