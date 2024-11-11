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

internal final class VxRevenueCat: @unchecked Sendable {
    
    public static let shared = VxRevenueCat()
    private init() {}
    
    public weak var delegate: VxRevenueCatDelegate?
    
    public var products : [StoreProduct] {
        return VxHub.shared.revenueCatProducts
    }
    
    internal func restorePurchases(completion: ((Bool) -> Void)? = nil) {
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                VxLogger.shared.error("Error restoring purchases: \(error)")
                self.delegate?.didRestorePurchases(didSucceed: false, error: error.localizedDescription)
                return
            }
            
            if customerInfo?.entitlements.all.isEmpty == false {
                completion?(true)
                self.delegate?.didRestorePurchases(didSucceed: true, error: nil)
            }else{
                completion?(false)
                self.delegate?.didRestorePurchases(didSucceed: false, error: "No entitlements found")
            }
        }
    }
    
    public func purchase(_ productToBuy: StoreProduct, completion: (@Sendable (Bool) -> Void)? = nil) {
        Purchases.shared.purchase(product: productToBuy) { transaction, customerInfo, error, userCancelled in
            if userCancelled {
                completion?(false)
                self.delegate?.didRestorePurchases(didSucceed: false, error: "User cancelled the purchase")
            }else{
                VxNetworkManager.shared.validatePurchase(transactionId: transaction?.transactionIdentifier ?? "COULD_NOT_FIND_TRANSACTION_ID")
                completion?(true)
                self.delegate?.didRestorePurchases(didSucceed: true, error: nil)
            }
        }
    }
    
    internal func requestRevenueCatProducts(completion: (([StoreProduct]) -> Void)? = nil) {
        guard Purchases.isConfigured else {
            VxLogger.shared.error("Error initializing purchases")
            self.delegate?.didFetchProducts(products: nil, error: "Error initializing purchases")
            completion?([])
            return
        }
        
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                VxLogger.shared.error("Error fetching offerings: \(error)")
                self.delegate?.didFetchProducts(products: nil, error: "\(error.localizedDescription)")
                completion?([])
                return
            }
            guard let offerings = offerings else { return }
            let products = offerings.current?.availablePackages.map({ $0.storeProduct })
            completion?(products ?? [])
            self.delegate?.didFetchProducts(products: products,error: nil)
        }
    }
}
