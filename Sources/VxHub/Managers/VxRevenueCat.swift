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

public struct VxStoreProduct {
    public let storeProduct : StoreProduct
    public let isDiscountOrTrialEligible: Bool
    public let initialBonus: Int?
    public let renewalBonus: Int?
}

internal final class VxRevenueCat: @unchecked Sendable {
    public init() {}
    
    public var products : [VxStoreProduct] {
        return VxHub.shared.revenueCatProducts
    }
    
    internal func restorePurchases(completion: ((Bool) -> Void)? = nil) {
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                VxLogger.shared.error("Error restoring purchases: \(error)")
                completion?(false)
                return
            }
            
            if let entitlements = customerInfo?.entitlements.all, !entitlements.isEmpty {
                var hasActiveEntitlement = false
                for (_, entitlement) in entitlements {
                    if entitlement.isActive {
                        hasActiveEntitlement = true
                        break
                    }
                }
                
                VxLogger.shared.info("Restored purchases: \(String(describing: customerInfo))")
                VxLogger.shared.info("User has active entitlement: \(hasActiveEntitlement)")
                completion?(hasActiveEntitlement)
            } else {
                VxLogger.shared.info("No entitlements found for restored purchases.")
                completion?(false)
            }
        }
    }

    
    public func purchase(_ productToBuy: StoreProduct, completion: (@Sendable (Bool) -> Void)? = nil) {
        Purchases.shared.purchase(product: productToBuy) { transaction, customerInfo, error, userCancelled in
            
            if let error {
                VxLogger.shared.error("Error purchasing product: \(error)")
                completion?(false)
                return
            }
            
            if userCancelled {
                completion?(false)
//                self.delegate?.didPurchaseComplete(didSucceed: false, error: "User cancelled the purchase") //TODO: - ADD DELEGATES LATER
            } else {
                if transaction?.transactionIdentifier != nil {
                    let networkManager = VxNetworkManager()
                    networkManager.validatePurchase(transactionId: transaction?.transactionIdentifier ?? "COULD_NOT_FIND_TRANSACTION_ID")
                    completion?(true)
                }else{
                    completion?(false)
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
