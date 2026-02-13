#if canImport(UIKit)
//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import UIKit

struct VxMainSubscriptionDataSourceModel: Hashable {
    let index: Int?
    public let id: Int?
    let identifier: String?
    let title: String?
    let description: String?
    let localizedPrice: String?
    let weeklyPrice: String?
    let monthlyPrice: String?
    let dailyPrice: String?
    let subPeriod: SubPreiod?
    var freeTrialPeriod: SubPreiod?
    let freeTrialUnit: Int?
    var initiallySelected: Bool = false
    let discountAmount: Int?
    var eligibleForFreeTrialOrDiscount: Bool?
    let font: VxFont?
    var isSelected: Bool = false
    
    var comparedPeriodPrice: String?
    var comparedPeriod: SubPreiod?
    
    var isBestOffer: Bool = false
    
    let isLightMode: Bool
    let textColor: UIColor
    
    let initialBonus: Int?
    let renewalBonus: Int?
    
    init(index: Int?,
         id: Int?,
         identifier: String?,
         title: String?,
         description: String?,
         localizedPrice: String?,
         weeklyPrice: String?,
         monthlyPrice: String?,
         dailyPrice: String?,
         subPeriod: SubPreiod?,
         freeTrialPeriod: SubPreiod?,
         freeTrialUnit: Int?,
         initiallySelected: Bool = false,
         discountAmount: Int?,
         eligibleForFreeTrialOrDiscount: Bool? = nil,
         baseFont: VxFont,
         isSelected: Bool = false,
         comparedPeriodPrice: String? = nil,
         comparedPeriod: SubPreiod? = nil,
         isBestOffer: Bool = false,
         isLightMode: Bool,
         textColor: UIColor,
         initialBonus: Int? = nil,
         renewalBonus: Int? = nil) {
        self.index = index
        self.id = id
        self.identifier = identifier
        self.title = title
        self.description = description
        self.localizedPrice = localizedPrice
        self.weeklyPrice = weeklyPrice
        self.monthlyPrice = monthlyPrice
        self.dailyPrice = dailyPrice
        self.subPeriod = subPeriod
        self.freeTrialPeriod = freeTrialPeriod
        self.freeTrialUnit = freeTrialUnit
        self.initiallySelected = initiallySelected
        self.discountAmount = discountAmount
        self.eligibleForFreeTrialOrDiscount = eligibleForFreeTrialOrDiscount
        self.font = baseFont
        self.isSelected = isSelected
        self.comparedPeriodPrice = comparedPeriodPrice
        self.comparedPeriod = comparedPeriod
        self.isBestOffer = isBestOffer
        self.isLightMode = isLightMode
        self.textColor = textColor
        self.initialBonus = initialBonus
        self.renewalBonus = renewalBonus
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
#endif
