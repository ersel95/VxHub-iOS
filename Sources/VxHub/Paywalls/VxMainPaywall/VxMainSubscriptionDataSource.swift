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
    var freeTrialUnit: Int?
    var initiallySelected: Bool = false
    let discountAmount: Int?
    var eligibleForFreeTrialOrDiscount: Bool?
    
    var comparedPeriodPrice: String?
//    var comparedPeriod: SubPreiod?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: VxMainSubscriptionDataSourceModel, rhs: VxMainSubscriptionDataSourceModel) -> Bool {
        return lhs.id == rhs.id
    }
    
}

enum VxMainSubscriptionDataSourceSection: Hashable {
    case main
}
