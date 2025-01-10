//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 10.01.2025.
//

import UIKit
import RevenueCat

enum VxSubscriptionPageTypes { //TODO: - Experiment keys BE den gelmeli
    case mainPaywall
    case welcomeOffer
    
    var experimentKey: String {
        switch self {
        case .welcomeOffer:
            return "welcome_offer"
        case .mainPaywall:
            return "main_paywall"
        }
    }
}

final class VxPaywallUtil {
    
    var storeProducts: [VxSubscriptionPageTypes: [SubData]] = [:]
    
    func setProducts() {
        self.setProducts(for: .mainPaywall)
        self.setProducts(for: .welcomeOffer)
    }
    
    public init() {
        self.setProducts()
    }
    
    
    func setProducts(for page: VxSubscriptionPageTypes) {
        let mainPayload = getPayload(for: page)
        
        var productsToAdd: [VxStoreProduct]
         
        if let mainProduct = mainPayload?.product { //single product
            productsToAdd = VxHub.shared.revenueCatProducts.filter {
                mainProduct.contains($0.storeProduct.productIdentifier)
            }
        } else if let mainProducts = mainPayload?.products { //multiple product
            productsToAdd = VxHub.shared.revenueCatProducts.filter {
                mainProducts.contains($0.storeProduct.productIdentifier)
            }
        } else {
            productsToAdd = VxHub.shared.revenueCatProducts
        }
        
        guard !productsToAdd.isEmpty else {
            return
        }
        
        let maxPrice = productsToAdd.compactMap { $0.storeProduct.price }.max() ?? 0
        
        if storeProducts[page] == nil {
            storeProducts[page] = []
        }
        
        for (index, product) in productsToAdd.enumerated() {
            var discountAmount: Int? = nil
            if product.storeProduct.price < maxPrice {
                let discountAmountDecimal = ((maxPrice - product.storeProduct.price) / maxPrice) * 100
                let decimalToInt = NSDecimalNumber(decimal: discountAmountDecimal).intValue
                discountAmount = decimalToInt
            }
            
            var introductoryPeriod : SubPreiod?
            if let introductoryDiscount = product.storeProduct.introductoryDiscount {
                
                if let _ = introductoryDiscount.sk1Discount,
                   introductoryDiscount.paymentMode == .freeTrial {
                    introductoryPeriod =  SubPreiod(rawValue: Int(product.storeProduct.introductoryDiscount?.subscriptionPeriod.unit.rawValue ?? 0))
                }
            }
            
            var introductoryCount : Int?
            if let introductoryDiscount = product.storeProduct.introductoryDiscount {
                    
                    if introductoryDiscount.subscriptionPeriod.unit == .day {
                        let value = introductoryDiscount.subscriptionPeriod.value
                        introductoryCount = value
                    }else if  introductoryDiscount.subscriptionPeriod.unit == .week {
                        let value = introductoryDiscount.subscriptionPeriod.value * 7
                        introductoryCount = value
                    }else if introductoryDiscount.subscriptionPeriod.unit == .month {
                        let value = introductoryDiscount.subscriptionPeriod.value * 30
                        introductoryCount = value
                    }else if introductoryDiscount.subscriptionPeriod.unit == .year {
                        let value = introductoryDiscount.subscriptionPeriod.value * 365
                        introductoryCount = value
                    }else {
                        let value = introductoryDiscount.subscriptionPeriod.value
                        introductoryCount = value
                    }
                    
                }
            
            var dailyPriceString: String?
            var monthlyPriceString: String?
            var weeklyPriceString: String?
            
            if SubPreiod(rawValue: product.storeProduct.subscriptionPeriod?.unit.rawValue ?? 0) == .year {
                let monthlyPrice = product.storeProduct.price / 12
                let currencySymbol0 = product.storeProduct.localizedPriceString.first ?? Character("")
                monthlyPriceString = "\(currencySymbol0)\(String(format: "%.2f", NSDecimalNumber(decimal: monthlyPrice).doubleValue))"
                
                let weeklyPrice = product.storeProduct.price / 52
                let currencySymbol = product.storeProduct.localizedPriceString.first ?? Character("")
                weeklyPriceString = "\(currencySymbol)\(String(format: "%.2f", NSDecimalNumber(decimal: weeklyPrice).doubleValue))"
                
                let dailyPrice = product.storeProduct.price / 365
                let currencySymbol2 = product.storeProduct.localizedPriceString.first ?? Character("")
                dailyPriceString = "\(currencySymbol2)\(String(format: "%.2f", NSDecimalNumber(decimal: dailyPrice).doubleValue))"
            }
            if SubPreiod(rawValue: product.storeProduct.subscriptionPeriod?.unit.rawValue ?? 0) == .month {
                let weeklyPrice = product.storeProduct.price / 4
                let currencySymbol = product.storeProduct.localizedPriceString.first ?? Character("")
                weeklyPriceString = "\(currencySymbol)\(String(format: "%.2f", NSDecimalNumber(decimal: weeklyPrice).doubleValue))"
                
                let dailyPrice = product.storeProduct.price / 30
                let currencySymbol2 = product.storeProduct.localizedPriceString.first ?? Character("")
                dailyPriceString = "\(currencySymbol2)\(String(format: "%.2f", NSDecimalNumber(decimal: dailyPrice).doubleValue))"
                
            }else if SubPreiod(rawValue: product.storeProduct.subscriptionPeriod?.unit.rawValue ?? 0) == .week {
                let dailyPrice = product.storeProduct.price / 7
                let currencySymbol = product.storeProduct.localizedPriceString.first ?? Character("")
                dailyPriceString = "\(currencySymbol)\(String(format: "%.2f", NSDecimalNumber(decimal: dailyPrice).doubleValue))"
            }
            
            let subData = SubData(
                id: index,
                identifier: product.storeProduct.productIdentifier,
                title: product.storeProduct.localizedTitle,
                description: product.storeProduct.localizedDescription,
                localizedPrice: product.storeProduct.localizedPriceString,
                weeklyPrice: weeklyPriceString ?? product.storeProduct.localizedPricePerWeek,
                monthlyPrice: monthlyPriceString ?? product.storeProduct.localizedPricePerMonth,
                dailyPrice: dailyPriceString,
                subPeriod: SubPreiod(rawValue: product.storeProduct.subscriptionPeriod?.unit.rawValue ?? 0),
                freeTrialPeriod: introductoryPeriod,
                freeTrialUnit: introductoryCount,
                initiallySelected: false,
                discountAmount: discountAmount,
                eligibleForFreeTrialOrDiscount: product.isDiscountOrTrialEligible
            )
            
//            UserManager.shared.isEligibleForFreeTrials[product.storeProduct.productIdentifier] = subData.eligibleForFreeTrialOrDiscount ?? true
            storeProducts[page]?.append(subData)
        }
        
        if page == .mainPaywall {
            // year > month > week > day
            storeProducts[page] = storeProducts[page]?.sorted(by: { lhs, rhs in
                guard let lhsPeriod = lhs.subPeriod?.rawValue, let rhsPeriod = rhs.subPeriod?.rawValue else {
                    return false
                }
                return lhsPeriod > rhsPeriod
            })


            if let lastSubData = storeProducts[page]?.last {
                if let firstSubData = storeProducts[page]?.first {
                    switch lastSubData.subPeriod {
                    case .day:
                        storeProducts[page]?[0].comparedPeriod = .day
                    case .week:
                        storeProducts[page]?[0].comparedPeriod = .week
                    case .month:
                        storeProducts[page]?[0].comparedPeriod = .month
                    case .year:
                        storeProducts[page]?[0].comparedPeriod = .year
                    default:
                        storeProducts[page]?[0].comparedPeriod = .year
                    }
                }
            }
        }

    }
    
    func getPayload(for page: VxSubscriptionPageTypes) -> ExperimentPayload? {
        guard let payload = VxHub.shared.getVariantPayload(for: page.experimentKey),
              !payload.isEmpty else {
            return nil
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            let decodedPayload = try JSONDecoder().decode(ExperimentPayload.self, from: jsonData)
            return decodedPayload
        } catch {
            debugPrint("Failed to decode payload:", error)
            return nil
        }
    }
}

enum PurchaseState: Int {
    case started, cancelled, failed, success
}

enum SubPreiod: Int, Codable {
    case day = 0
    case week = 1
    case month = 2
    case year = 3
    
    var contentText: String {
        switch self {
        case .day: return VxLocalizables.Subscription.welcomeOfferDailyText
        case .week: return VxLocalizables.Subscription.welcomeOfferWeeklyText
        case .month: return VxLocalizables.Subscription.welcomeOfferMonthlyText
        case .year: return VxLocalizables.Subscription.welcomeOfferYearlyText
        }
    }
    
    var notEligibleContentText : String {
        switch self {
        case .day: return VxLocalizables.Subscription.notEligibleWelcomeOfferDailyText
        case .week: return VxLocalizables.Subscription.notEligibleWelcomeOfferWeeklyText
        case .month: return VxLocalizables.Subscription.notEligibleWelcomeOfferMonthlyText
        case .year: return VxLocalizables.Subscription.notEligibleWelcomeOfferYearlyText
        }
    }
    
    var optionText : String {
        switch self {
        case .day: return VxLocalizables.Subscription.dailyOfferOptionText
        case .week: return VxLocalizables.Subscription.weeklyOfferOptionText
        case .month: return VxLocalizables.Subscription.monthlyOfferOptionText
        case .year: return VxLocalizables.Subscription.yearlyOfferOptionText
        }
    }
    var thenPeriodlyLabel: String {
        switch self {
        case .day: return VxLocalizables.Subscription.dailyThenText
        case .week: return VxLocalizables.Subscription.weeklyThenText
        case .month: return VxLocalizables.Subscription.monthlyThenText
        case .year: return VxLocalizables.Subscription.yearlyThenText
        }
    }
    
    var justPeriodLabel: String {
        VxLocalizables.Subscription.yearlyJustText
    }
    
    var periodText: String {
        switch self {
        case .day: return VxLocalizables.Subscription.dailyPerText
        case .week: return VxLocalizables.Subscription.weeklyPerText
        case .month: return VxLocalizables.Subscription.monthlyPerText
        case .year: return VxLocalizables.Subscription.yearlyPerText
        }
    }
    
    var periodWithoutPerStr: String {
        switch self {
        case .day: return VxLocalizables.Subscription.freeTrialMultipleDays
        case .week: return VxLocalizables.Subscription.freeTrialMultipleWeeks
        case .month: return VxLocalizables.Subscription.freeTrialMultipleMonths
        case .year: return VxLocalizables.Subscription.freeTrialMultipleYears
        }
    }
    
    var periodString: String {
        switch self {
        case .day: return VxLocalizables.Subscription.periodDailyText
        case .week: return VxLocalizables.Subscription.periodWeeklyText
        case .month: return VxLocalizables.Subscription.periodMonthlyText
        case .year: return VxLocalizables.Subscription.periodYearlyText
        }
    }
    
    func freeTrialString(value: Int) -> String {
        switch self {
        case .day:
            if value <= 0 {
                return VxLocalizables.Subscription.freeTrialDay.replaceKeyReplacing(toBeReplaced: String(value))
            } else {
                return VxLocalizables.Subscription.freeTrialMultipleDays.replaceKeyReplacing(toBeReplaced: String(value))
            }
        case .week:
            if value <= 0 {
                return VxLocalizables.Subscription.freeTrialWeek.replaceKeyReplacing(toBeReplaced: String(value))
            } else {
                return VxLocalizables.Subscription.freeTrialMultipleWeeks.replaceKeyReplacing(toBeReplaced: String(value))
            }
        case .month:
            if value <= 0 {
                return VxLocalizables.Subscription.freeTrialMonth.replaceKeyReplacing(toBeReplaced: String(value))
            } else {
                return VxLocalizables.Subscription.freeTrialMultipleMonths.replaceKeyReplacing(toBeReplaced: String(value))
            }
        case .year:
            if value <= 0 {
                return VxLocalizables.Subscription.freeTrialYear.replaceKeyReplacing(toBeReplaced: String(value))
            } else {
                return VxLocalizables.Subscription.freeTrialMultipleYears.replaceKeyReplacing(toBeReplaced: String(value))
            }
        }
    }
}


public struct SubData: Codable, Identifiable {
    public let id: Int?
    let identifier: String?
    let title: String?
//    let dollarPrice: String?
    let description: String?
    let localizedPrice: String?
    let weeklyPrice: String?
    let monthlyPrice: String?
    let dailyPrice: String?
    let subPeriod: SubPreiod?
    var freeTrialPeriod: SubPreiod?
    var freeTrialUnit: Int?
    var initiallySelected: Bool = false
    let discountAmount: Int?
    var eligibleForFreeTrialOrDiscount: Bool?
    
    var comparedPeriodPrice: String?
    var comparedPeriod: SubPreiod?
}
struct ExperimentPayload: Codable {
    let product: String? // Defined in amplitude as String
    let products: [String]? // Defined in amplitude as [String]
    let selectedIndex: Int?
}
