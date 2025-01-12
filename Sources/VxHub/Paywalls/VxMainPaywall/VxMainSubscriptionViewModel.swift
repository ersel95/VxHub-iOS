//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import Foundation
import Combine

public final class VxMainSubscriptionViewModel: @unchecked Sendable{
    let configuration: VxMainPaywallConfiguration
    var cellViewModels = [VxMainSubscriptionDataSourceModel]()
    public var onClose: (@Sendable () -> Void)?
    var onPurchaseSuccess: ( @Sendable() -> Void)?
    var onDismiss: (@Sendable() -> Void)?
    
    let freeTrialSwitchState = PassthroughSubject<Bool, Never>()
    var selectedPackagePublisher = CurrentValueSubject<VxMainSubscriptionDataSourceModel?, Never>(nil)
    
    public init(configuration: VxMainPaywallConfiguration, 
                onPurchaseSuccess: @escaping @Sendable () -> Void,
                onDismiss: @escaping @Sendable () -> Void) {
        self.configuration = configuration
        self.onPurchaseSuccess = onPurchaseSuccess
        self.onDismiss = onDismiss
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
                baseFont: configuration.fontFamily,
                isSelected: data.initiallySelected,
                comparedPeriodPrice: data.comparedPeriodPrice,
                comparedPeriod: data.comparedPeriod,
                isBestOffer: data.isBestOffer,
                isLightMode: configuration.isLightMode,
                textColor: configuration.textColor
            )
        }
        
        if let selectedProduct = cellViewModels.first(where: {$0.initiallySelected == true}) {
            self.selectedPackagePublisher.value = selectedProduct
        }else{
            self.selectedPackagePublisher.value = cellViewModels.first
        }
    }
    
    func closeButtonTapped() {
        onClose?()
        onDismiss?()
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
        
        selectedPackagePublisher.send(selectedProduct)
        freeTrialSwitchState.send(selectedProduct.eligibleForFreeTrialOrDiscount ?? false)
        
        if let selectedProduct = VxHub.shared.revenueCatProducts.first(where: {$0.storeProduct.productIdentifier == identifier }) {
            VxHub.shared.purchase(selectedProduct.storeProduct) {  success in
                    if success {
                        self.onPurchaseSuccess?()
                    }
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
                title: "Yearly Junk SMS Blocker",
                description: "Yearly Junk SMS Blocker Subscription",
                localizedPrice: "$29.99",
                weeklyPrice: "$0.58",
                monthlyPrice: "$2.50",
                dailyPrice: "$0.08",
                subPeriod: .year,
                freeTrialPeriod: nil,
                freeTrialUnit: nil,
                initiallySelected: true,
                discountAmount: nil,
                eligibleForFreeTrialOrDiscount: false,
                comparedPeriodPrice: nil,
                comparedPeriod: .month,
                isBestOffer: true
            ),
            SubData(
                id: 1,
                identifier: "monthly_trial",
                title: "Monthly Junk SMS Blocker",
                description: "Monthly Junk SMS Blocker Subscription",
                localizedPrice: "$3.99",
                weeklyPrice: "$1.00",
                monthlyPrice: "$3.99",
                dailyPrice: "$0.13",
                subPeriod: .month,
                freeTrialPeriod: nil,
                freeTrialUnit: 3,
                initiallySelected: false,
                discountAmount: 0,
                eligibleForFreeTrialOrDiscount: true,
                comparedPeriodPrice: nil,
                comparedPeriod: nil,
                isBestOffer: false
            )
        ]
    }
}
