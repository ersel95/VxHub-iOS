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
    case all
    
    var experimentKey: String {
        switch self {
        case .welcomeOffer:
            return "welcome_offer"
        case .mainPaywall:
            return "main_paywall"
        case .all:
            return "all_available_products_9999" // Not exist in amplitude
            
        }
    }
}

final class VxPaywallUtil {
    
    var storeProducts: [VxSubscriptionPageTypes: [SubData]] = [:]
    let initiallySelectedProductIdentifier: String? = VxHub.shared.remoteConfig["subscription_selected_product_identifier"] as? String
    
    func setProducts() {
        self.setProducts(for: .mainPaywall)
        self.setProducts(for: .welcomeOffer)
        self.setProducts(for: .all)
    }
    
    public init() {
        self.setProducts()
    }
    
    
    func setProducts(for page: VxSubscriptionPageTypes) {
        var productsToAdd: [VxStoreProduct]
        let renewableSubs = VxHub.shared.revenueCatProducts.filter({ $0.storeProduct.productType == .autoRenewableSubscription })

        let hasAmplitude = VxHub.shared.deviceInfo?.thirdPartyInfos?.amplitudeApiKey != nil
        let mainPayload: ExperimentPayload? = hasAmplitude ? getPayload(for: page) : nil

        if let mainProduct = mainPayload?.product { //single product
            productsToAdd = renewableSubs.filter {
                mainProduct.contains($0.storeProduct.productIdentifier)
            }
        } else if let mainProducts = mainPayload?.products { //multiple product
            productsToAdd = renewableSubs.filter {
                mainProducts.contains($0.storeProduct.productIdentifier)
            }

        } else {
            if hasAmplitude {
                VxLogger.shared.log("Could not get experiment for \(page.experimentKey)", level: .warning)
            }
            productsToAdd = renewableSubs
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
            
            if SubPreiod(rawValue: product.storeProduct.subscriptionPeriod?.unit.rawValue ?? 0) == .year {
                let monthlyPrice = product.storeProduct.price / 12
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = product.storeProduct.priceFormatter?.locale ?? Locale.current

                monthlyPriceString = formatter.string(from: NSDecimalNumber(decimal: monthlyPrice)) ?? product.storeProduct.localizedPriceString

                let dailyPrice = product.storeProduct.price / 365
                dailyPriceString = formatter.string(from: NSDecimalNumber(decimal: dailyPrice)) ?? product.storeProduct.localizedPriceString
            }
            if SubPreiod(rawValue: product.storeProduct.subscriptionPeriod?.unit.rawValue ?? 0) == .month {
                let dailyPrice = product.storeProduct.price / 30
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = product.storeProduct.priceFormatter?.locale ?? Locale.current
                dailyPriceString = formatter.string(from: NSDecimalNumber(decimal: dailyPrice)) ?? product.storeProduct.localizedPriceString

            }else if SubPreiod(rawValue: product.storeProduct.subscriptionPeriod?.unit.rawValue ?? 0) == .week {
                let dailyPrice = product.storeProduct.price / 7
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = product.storeProduct.priceFormatter?.locale ?? Locale.current
                dailyPriceString = formatter.string(from: NSDecimalNumber(decimal: dailyPrice)) ?? product.storeProduct.localizedPriceString
            }
            
            let nonDiscountedProductId = mainPayload?.nonDiscountedProductId
            let nonDiscountPrice = VxHub.shared.revenueCatProducts.first(where: {$0.storeProduct.productIdentifier == nonDiscountedProductId })?.storeProduct.localizedPriceString
            
            let subData = SubData(
                id: index,
                identifier: product.storeProduct.productIdentifier,
                title: product.storeProduct.localizedTitle,
                description: product.storeProduct.localizedDescription,
                localizedPrice: product.storeProduct.localizedPriceString,
                weeklyPrice: product.storeProduct.localizedPricePerWeek,
                monthlyPrice: monthlyPriceString ?? product.storeProduct.localizedPricePerMonth,
                dailyPrice: dailyPriceString,
                subPeriod: SubPreiod(rawValue: product.storeProduct.subscriptionPeriod?.unit.rawValue ?? 0),
                freeTrialPeriod: introductoryPeriod,
                freeTrialUnit: introductoryCount,
                initiallySelected: false,
                discountAmount: discountAmount,
                eligibleForFreeTrialOrDiscount: product.isDiscountOrTrialEligible,
                isBestOffer: false,
                initial_bonus: product.initialBonus,
                renewal_bonus: product.renewalBonus,
                productType: RevenueCatProductType(rawValue: product.storeProduct.productType.rawValue) ?? .autoRenewableSubscription,
                nonDiscountedPrice: nonDiscountPrice,
                price: product.storeProduct.price
            )
            
            
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

            if let fIndex = self.storeProducts[page]?.firstIndex(where: { $0.identifier == initiallySelectedProductIdentifier }) {
                storeProducts[page]?[fIndex].initiallySelected = true
            }else{
                if storeProducts[page]?.isEmpty == false {
                    storeProducts[page]?[0].initiallySelected = true
                }
            }

            if storeProducts[page] != nil { //TODO: - Compare best offer according to daily price
                if !storeProducts[page]!.isEmpty  {
                    storeProducts[page]![0].isBestOffer = true
                }
            }

            if let lastSubData = storeProducts[page]?.last {
                if storeProducts[page]?.first != nil {
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
    
    private func getPayload(for page: VxSubscriptionPageTypes) -> ExperimentPayload? {
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

enum RevenueCatProductType: Int, Codable {
    case consumable, nonConsumable, nonRenewableSubscription, autoRenewableSubscription
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
        switch self {
        case .day: return VxLocalizables.Subscription.dailyPerText
        case .week: return VxLocalizables.Subscription.weeklyPerText
        case .month: return VxLocalizables.Subscription.monthlyPerText
        case .year: return VxLocalizables.Subscription.yearlyJustText
        }
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
    
    
    var singlePeriodString: String {
        switch self {
        case .day: return VxLocalizables.Subscription.singlePeriodDayText
        case .week: return VxLocalizables.Subscription.singlePeriodWeekText
        case .month: return VxLocalizables.Subscription.singlePeriodMonthText
        case .year: return VxLocalizables.Subscription.singlePeriodYearText
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
    var isBestOffer: Bool
    var initial_bonus: Int?
    var renewal_bonus: Int?
    var productType: RevenueCatProductType
    var nonDiscountedPrice: String?
    var price: Decimal?
}

struct ExperimentPayload: Codable {
    let product: String?
    let nonDiscountedProductId: String?
    let products: [String]?
    let selectedIndex: Int?
    
    enum CodingKeys: String, CodingKey {
        case product
        case nonDiscountedProductId = "non_discounted_product_id"
        case products
        case selectedIndex
    }
}
