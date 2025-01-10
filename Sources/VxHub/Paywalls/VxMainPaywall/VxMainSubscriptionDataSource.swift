//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import Foundation

struct VxMainSubscriptionDataSourceModel: Hashable {
    public let id: Int?
    let identifier: String?
    let title: String?
//    let dollarPrice: String?
    let description: String?
    let localizedPrice: String?
    let weeklyPrice: String?
    let monthlyPrice: String?
    let dailyPrice: String?
//    let subPeriod: SubPreiod?
//    var freeTrialPeriod: SubPreiod?
    let freeTrialUnit: Int?
    var initiallySelected: Bool = false
    let discountAmount: Int?
    var eligibleForFreeTrialOrDiscount: Bool?
    let baseFont: String
    var isSelected: Bool = false
    
    var comparedPeriodPrice: String?
//    var comparedPeriod: SubPreiod?
    
    init(id: Int?,
         identifier: String?,
         title: String?,
         description: String?,
         localizedPrice: String?,
         weeklyPrice: String?,
         monthlyPrice: String?,
         dailyPrice: String?,
         freeTrialUnit: Int?,
         discountAmount: Int?,
         baseFont: String,
         isSelected: Bool = false) {
        self.id = id
        self.identifier = identifier
        self.title = title
        self.description = description
        self.localizedPrice = localizedPrice
        self.weeklyPrice = weeklyPrice
        self.monthlyPrice = monthlyPrice
        self.dailyPrice = dailyPrice
        self.freeTrialUnit = freeTrialUnit
        self.discountAmount = discountAmount
        self.baseFont = baseFont
        self.isSelected = isSelected
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isSelected)
    }

    static func == (lhs: VxMainSubscriptionDataSourceModel, rhs: VxMainSubscriptionDataSourceModel) -> Bool {
        return lhs.id == rhs.id && lhs.isSelected == rhs.isSelected
    }
    
}

enum VxMainSubscriptionDataSourceSection: Hashable {
    case main
}
