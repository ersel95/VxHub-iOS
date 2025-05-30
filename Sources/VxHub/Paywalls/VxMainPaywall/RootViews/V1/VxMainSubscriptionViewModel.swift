//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import Foundation
import Combine
import UIKit

protocol VxMainSuvscriptionViewModelDelegate: AnyObject{
    func dismiss()
}

public final class VxMainSubscriptionViewModel: @unchecked Sendable{
    let configuration: VxMainPaywallConfiguration
    var cellViewModels = [VxMainSubscriptionDataSourceModel]()
    
    let freeTrialSwitchState = PassthroughSubject<Bool, Never>()
    var selectedPackagePublisher = CurrentValueSubject<VxMainSubscriptionDataSourceModel?, Never>(nil)
    let loadingStatePublisher = CurrentValueSubject<Bool, Never>(false)
    
    var onPurchaseSuccess: (@Sendable(String?) -> Void)?
    var onDismissWithoutPurchase: (@Sendable() -> Void)?
    var onRestoreAction: (@Sendable(Bool) -> Void)?
    var onReedemCodaButtonTapped: (@Sendable() -> Void)?
    
    weak var delegate: VxMainSuvscriptionViewModelDelegate?
    
    public init(
        configuration: VxMainPaywallConfiguration,
        onPurchaseSuccess: @escaping @Sendable (String?) -> Void,
        onDismissWithoutPurchase: @escaping @Sendable () -> Void,
        onRestoreAction: @escaping @Sendable (Bool) -> Void,
        onReedemCodaButtonTapped: @escaping @Sendable () -> Void) {
            self.configuration = configuration
            self.onPurchaseSuccess = onPurchaseSuccess
            self.onDismissWithoutPurchase = onDismissWithoutPurchase
            self.onRestoreAction = onRestoreAction
            self.onReedemCodaButtonTapped = onReedemCodaButtonTapped
            let paywallUtil = VxPaywallUtil()
            var data = paywallUtil.storeProducts[.mainPaywall] ?? [SubData]()
            if data.isEmpty {
                data = getDummyData()
            }
            self.initializeCells(with: data)
        }
    
    func initializeCells(with subData: [SubData]) {
        self.cellViewModels = subData.enumerated().map { index, data in
            VxMainSubscriptionDataSourceModel(
                index: index,
                id: data.id,
                identifier: data.identifier,
                title: data.title,
                description: data.description,
                localizedPrice: data.localizedPrice,
                weeklyPrice: data.weeklyPrice,
                monthlyPrice: data.monthlyPrice,
                dailyPrice: data.dailyPrice,
                subPeriod: data.subPeriod,
                freeTrialPeriod: data.freeTrialPeriod,
                freeTrialUnit: data.freeTrialUnit,
                initiallySelected: data.initiallySelected,
                discountAmount: data.discountAmount,
                eligibleForFreeTrialOrDiscount: data.eligibleForFreeTrialOrDiscount,
                baseFont: configuration.font,
                isSelected: data.initiallySelected,
                comparedPeriodPrice: data.comparedPeriodPrice,
                comparedPeriod: data.comparedPeriod,
                isBestOffer: data.isBestOffer,
                isLightMode: configuration.isLightMode,
                textColor: configuration.textColor,
                initialBonus: data.initial_bonus,
                renewalBonus: data.renewal_bonus
            )
        }
        
        if let selectedProduct = cellViewModels.first(where: {$0.initiallySelected == true}) {
            self.selectedPackagePublisher.value = selectedProduct
        }else{
            self.selectedPackagePublisher.value = cellViewModels.first
        }
    }
    
    internal func dismiss() {
        self.delegate?.dismiss()
    }
    
    func handleFreeTrialSwitchChange(isOn: Bool) {
        cellViewModels.indices.forEach { index in
            cellViewModels[index].isSelected = isOn ?
            (cellViewModels[index].eligibleForFreeTrialOrDiscount == true) :
            (cellViewModels[index].eligibleForFreeTrialOrDiscount == false)
        }
        freeTrialSwitchState.send(isOn)
    }
    
    func handleProductSelection(identifier: String?) {
        guard let selectedProduct = cellViewModels.first(where: { $0.identifier == identifier }) else { return }
        
        cellViewModels.indices.forEach { index in
            cellViewModels[index].isSelected = cellViewModels[index].identifier == identifier
        }
        
        if self.configuration.analyticsEvents?.contains(.select) == true {
            var eventProperties = ["product_identifier": identifier]
            eventProperties["page_name"] = "subscription_landing"
            VxHub.shared.logAmplitudeEvent(eventName: AnalyticEvents.select.formattedName, properties: eventProperties as [AnyHashable : Any])
        }
        
        selectedPackagePublisher.send(selectedProduct)
        freeTrialSwitchState.send(selectedProduct.eligibleForFreeTrialOrDiscount ?? false)
        
        purchaseAction()
    }
    
    func purchaseAction() {
        if VxHub.shared.isConnectedToInternet == false {
            DispatchQueue.main.async {
                guard let topVc = UIApplication.shared.topViewController() else { return }
                VxAlertManager.shared.present(
                    title: VxLocalizables.InternetConnection.checkYourInternetConnection,
                    message: VxLocalizables.InternetConnection.checkYourInternetConnectionDescription,
                    buttonTitle: VxLocalizables.InternetConnection.checkYourInternetConnectionButtonLabel,
                    from: topVc)
            }
            return
        }
        
        guard self.loadingStatePublisher.value == false else { return }
        guard let selectedProduct = selectedPackagePublisher.value,
              let identifier = selectedProduct.identifier,
              let revenueCatProduct = VxHub.shared.revenueCatProducts.first(where: {$0.storeProduct.productIdentifier == identifier }) else { return }
        
        self.loadingStatePublisher.send(true)
        VxHub.shared.purchase(revenueCatProduct.storeProduct) { [weak self] success in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if success {
//                    VxHub.shared.start { isSuccess in
                        self.onPurchaseSuccess?(identifier)
                        self.loadingStatePublisher.send(false)
//                    }
                }else{
                    self.loadingStatePublisher.send(false)
                }
            }
        }
    }
    
    func restoreAction() {
        self.loadingStatePublisher.send(true)
        VxHub.shared.restorePurchases { [weak self] hasActiveSubscription, hasActiveNonConsumable, error in
            if hasActiveSubscription {
                self?.onPurchaseSuccess?(nil)
                self?.onRestoreAction?(true)
            }else{
                self?.onRestoreAction?(false)
                self?.loadingStatePublisher.send(false)
            }
        }
    }
}

extension VxMainSubscriptionViewModel {
    func getDummyData() -> [SubData] {
        return [
            SubData(
                id: 0,
                identifier: "yearly_subscription",
                title: "FAILED TO LOAD",
                description: "",
                localizedPrice: "$0.00",
                weeklyPrice: "$0.00",
                monthlyPrice: "$0.00",
                dailyPrice: "$0.00",
                subPeriod: .year,
                freeTrialPeriod: nil,
                freeTrialUnit: nil,
                initiallySelected: true,
                discountAmount: nil,
                eligibleForFreeTrialOrDiscount: false,
                comparedPeriodPrice: nil,
                comparedPeriod: .month,
                isBestOffer: true,
                productType: .autoRenewableSubscription
            ),
            SubData(
                id: 1,
                identifier: "monthly_trial",
                title: "FAILED TO LOAD",
                description: "",
                localizedPrice: "$0.00",
                weeklyPrice: "$0.00",
                monthlyPrice: "$0.00",
                dailyPrice: "$0.00",
                subPeriod: .month,
                freeTrialPeriod: nil,
                freeTrialUnit: 3,
                initiallySelected: false,
                discountAmount: 0,
                eligibleForFreeTrialOrDiscount: true,
                comparedPeriodPrice: nil,
                comparedPeriod: nil,
                isBestOffer: false,
                productType: .autoRenewableSubscription
            )
        ]
    }
}
