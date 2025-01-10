//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import Foundation

public final class VxMainSubscriptionViewModel {
    let configuration: VxMainPaywallConfiguration
    var cellViewModels = [VxMainSubscriptionDataSourceModel]()
    
    public init(configuration: VxMainPaywallConfiguration) {
        self.configuration = configuration
        
        let paywallUtil = VxPaywallUtil()
        let data = paywallUtil.storeProducts[.mainPaywall] ?? [SubData]()
        
        self.setCells(with: data)
    }
    
    func setCells(with subData: [SubData]) {
        self.cellViewModels = subData.enumerated().map { index, data in
            VxMainSubscriptionDataSourceModel(
                id: data.id,
                identifier: data.identifier,
                title: data.title,
                dollarPrice: nil,
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
                baseFont: configuration.baseFont,
                isSelected: index == 0,
                comparedPeriodPrice: data.comparedPeriodPrice,
                comparedPeriod: data.comparedPeriod
            )
        }
    }
}
