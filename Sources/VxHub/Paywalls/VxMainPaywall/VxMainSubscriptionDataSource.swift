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
    let baseFont: String
    var isSelected: Bool = false
    
    var comparedPeriodPrice: String?
    var comparedPeriod: SubPreiod?
    
    var isBestOffer: Bool = false
    
    init(id: Int?,
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
         baseFont: String,
         isSelected: Bool = false,
         comparedPeriodPrice: String? = nil,
         comparedPeriod: SubPreiod? = nil,
         isBestOffer: Bool = false) {
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
        self.baseFont = baseFont
        self.isSelected = isSelected
        self.comparedPeriodPrice = comparedPeriodPrice
        self.comparedPeriod = comparedPeriod
        self.isBestOffer = isBestOffer
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
