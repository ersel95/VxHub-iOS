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
        self.setCells(with: configuration)
    }
    
    func setCells(with config: VxMainPaywallConfiguration) {
        let cellViewModels = [
            VxMainSubscriptionDataSourceModel(
                id: 1,
                identifier: "monthly",
                title: "Monthly Plan",
                description: "Monthly subscription",
                localizedPrice: "$9.99",
                weeklyPrice: "",
                monthlyPrice: "$9.99",
                dailyPrice: "",
                freeTrialUnit: 1,
                discountAmount: 0,
                baseFont: configuration.baseFont,
                isSelected: true
            ),
            VxMainSubscriptionDataSourceModel(
                id: 2,
                identifier: "yearly",
                title: "Yearly Plan",
                description: "Yearly subscription",
                localizedPrice: "$99.99",
                weeklyPrice: "",
                monthlyPrice: "$8.33",
                dailyPrice: "",
                freeTrialUnit: 1,
                discountAmount: 20,
                baseFont: configuration.baseFont,
                isSelected: false
            )
        ]
        self.cellViewModels = cellViewModels
    }
    
}
