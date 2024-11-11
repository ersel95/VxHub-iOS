//
//  File.swift
//  VxHub
//
//  Created by furkan on 11.11.2024.
//

import Foundation
import RevenueCat

public final class VxRevenueCat: @unchecked Sendable {
    
    static let shared = VxRevenueCat()
    private init() {}
    
    internal func requestRevenueCatProducts(completion: @escaping([StoreProduct]) -> Void) {
        guard Purchases.isConfigured else {
            VxLogger.shared.error("Error initializing purchases")
            return
        }
        
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                VxLogger.shared.error("Error fetching offerings: \(error)")
                return
            }
            guard let offerings = offerings else { return }
            let products = offerings.current?.availablePackages.map({ $0.storeProduct })
            completion(products ?? [])
        }
    }
    
    internal func restorePurchases(completion: @escaping(Bool) ->Void) {
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                VxLogger.shared.error("Error restoring purchases: \(error)")
                return
            }
            
            if customerInfo?.entitlements.all.isEmpty == false {
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    internal func purchase(_ productToBuy: StoreProduct, completion: @escaping @Sendable(Bool) -> Void) {
        Purchases.shared.purchase(product: productToBuy) { transaction, customerInfo, error, userCancelled in
            if userCancelled {
                completion(false)
            }else{
                VxNetworkManager.shared.validatePurchase(transactionId: transaction?.transactionIdentifier ?? "COULD_NOT_FIND_TRANSACTION_ID")
                completion(true)
            }
        }
    }
}
