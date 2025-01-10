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
    var onClose: (() -> Void)?
    
    public init(configuration: VxMainPaywallConfiguration) {
        self.configuration = configuration
        
        let paywallUtil = VxPaywallUtil()
        var data = paywallUtil.storeProducts[.mainPaywall] ?? [SubData]()
        
        if data.isEmpty {
            data = getDummyData()
        }
        
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
    
    func closeButtonTapped() {
        onClose?()
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
                initiallySelected: false,
                discountAmount: nil,
                eligibleForFreeTrialOrDiscount: false,
                comparedPeriodPrice: nil,
                comparedPeriod: .month
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
                comparedPeriod: nil
            )
        ]
    }
}
