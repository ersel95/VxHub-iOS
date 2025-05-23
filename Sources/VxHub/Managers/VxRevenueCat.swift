//
//  File.swift
//  VxHub
//
//  Created by furkan on 11.11.2024.
//

import Foundation
import RevenueCat

internal protocol VxRevenueCatDelegate: AnyObject {
    func didPurchaseComplete(didSucceed: Bool, error: String?)
    func didRestorePurchases(didSucceed: Bool, error: String?)
    func didFetchProducts(products: [StoreProduct]?, error: String?)
}

public enum VxProductType: Int {
    case consumable
    case nonConsumable
    case nonRenewalSubscription
    case renewalSubscription
}

public struct VxStoreProduct {
    public let storeProduct: StoreProduct
    public let isDiscountOrTrialEligible: Bool
    public let initialBonus: Int?
    public let renewalBonus: Int?
    public let vxProductType: VxProductType?
}

internal final class VxRevenueCat: @unchecked Sendable {
    public init() {}
    
    public var products : [VxStoreProduct] {
        return VxHub.shared.revenueCatProducts
    }
    
    //hasActiveSubscription, hasActiveNonConsumable, hasError
    internal func restorePurchases(completion: (@Sendable (Bool, Bool, String?) -> Void)? = nil) {
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
                let hasActiveNonConsumable = customerInfo.nonConsumablePurchases
                completion?(hasActiveSubscription, hasActiveNonConsumable.isEmpty, nil)
            }
        }
    }

    
    public func purchase(_ productToBuy: StoreProduct, completion: (@Sendable (Bool, StoreTransaction?) -> Void)? = nil) {
        Purchases.shared.purchase(product: productToBuy) { transaction, customerInfo, error, userCancelled in
            if let error {
                VxLogger.shared.error("Error purchasing product: \(error)")
                completion?(false, transaction)
                return
            }
            
            if userCancelled {
                completion?(false, transaction)
//                self.delegate?.didPurchaseComplete(didSucceed: false, error: "User cancelled the purchase") //TODO: - ADD DELEGATES LATER
            } else {
                if transaction?.transactionIdentifier != nil {
                    let networkManager = VxNetworkManager()
                    networkManager.validatePurchase(transactionId: transaction?.transactionIdentifier ?? "COULD_NOT_FIND_TRANSACTION_ID")
                    debugPrint("Result geldi transaction 1")
                    completion?(true, transaction)
                } else {
                    debugPrint("Result geldi transaction 2")
                    completion?(false, transaction)
                }
//                self.delegate?.didPurchaseComplete(didSucceed: true, error: nil) //TODO: - ADD DELEGATES LATER
            }
        }
    }
    
    internal func requestRevenueCatProducts(completion: (([StoreProduct]) -> Void)? = nil) {
        guard Purchases.isConfigured else {
            VxLogger.shared.error("Error initializing purchases")
//            self.delegate?.didFetchProducts(products: nil, error: "Error initializing purchases") //TODO: - ADD DELEGATES LATER
            completion?([])
            return
        }
        
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                VxLogger.shared.error("Error fetching offerings: \(error)")
//                self.delegate?.didFetchProducts(products: nil, error: "\(error.localizedDescription)") //TODO: - ADD DELEGATES LATER
                completion?([])
                return
            }
            guard let offerings = offerings else {
                completion?([])
                return }
            let products = offerings.current?.availablePackages.map({ $0.storeProduct })
            completion?(products ?? [])
//            self.delegate?.didFetchProducts(products: products,error: nil) //TODO: - ADD DELEGATES LATER
        }
    }
}
