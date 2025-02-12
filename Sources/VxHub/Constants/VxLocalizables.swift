//
//  File.swift
//  VxHub
//
//  Created by furkan on 2.01.2025.
//

import Foundation

public enum VxLocalizables {
    public enum Permission {
        static public let microphoneAccessRequiredTitle = "VxPermissions_Default_MicrophoneAccessRequiredTitle".localize()
        static public let microphoneAccessRequiredMessage = "VxPermissions_Default_MicrophoneAccessRequiredMessage".localize()
        static public let microphoneAccessButtonTitle = "VxPermissions_Default_MicrophoneAccessButtonTitle".localize()
        static public let cameraAccessRequiredTitle = "VxPermissions_Default_CameraAccessRequiredTitle".localize()
        static public let cameraAccessRequiredMessage = "VxPermissions_Default_CameraAccessRequiredMessage".localize()
        static public let cameraAccessButtonTitle = "VxPermissions_Default_CameraAccessButtonTitle".localize()
        static public let settingsButtonTitle = "VxPermissions_Default_SettingsButtonTitle".localize()
        static public let cancelButtonTitle = "VxPermissions_Default_CancelButtonTitle".localize()
        static public let fileAccessRequiredTitle = "VxPermissions_Default_FileAccessRequiredTitle".localize()
        static public let fileAccessRequiredMessage = "VxPermissions_Default_FileAccessRequiredMessage".localize()
        static public let galleryAccessRequiredTitle = "VxPermissions_Default_GalleryAccessRequiredTitle".localize()
        static public let galleryAccessRequiredMessage = "VxPermissions_Default_GalleryAccessRequiredMessage".localize()
        static public let galleryAccessButtonTitle = "VxPermissions_Default_GalleryAccessButtonTitle".localize()
        static public let photoLibraryAccessRequiredTitle = "VxPermissions_Default_PhotoLibraryAccessRequiredTitle".localize()
        static public let photoLibraryAccessRequiredMessage = "VxPermissions_Default_PhotoLibraryAccessRequiredMessage".localize()
        static public let photoLibraryAccessButtonTitle = "VxPermissions_Default_PhotoLibraryAccessButtonTitle".localize()
    }
    
    enum Subscription {
        static var subscribeButtonLabel: String { "Subscription_SubscribeButtonLabel".localize() }
        static var restorePurchaseLabel: String { "Subscription_RestorePurchase".localize() }
        static var termsOfUse: String { "Subscription_TermsOfUse".localize() }
        static var privacyPol: String { "Subscription_PrivacyPol".localize() }
        static var reedemCode: String { "Subscription_ReedemCode".localize() }
        
        static var headerBodyText: String { "Subscription_HeaderBodyText".localize() }
        static var freeTrailEnabledLabel: String { "Subscription_FreeTrailEnabledLabel".localize() }
        
        static var welcomeOfferYearlyText: String { "Subscription_WelcomeOfferYearlyText".localize() }
        static var welcomeOfferMonthlyText: String { "Subscription_WelcomeOfferMonthlyText".localize() }
        static var welcomeOfferDailyText: String { "Subscription_WelcomeOfferDailyText".localize() }
        static var welcomeOfferWeeklyText: String { "Subscription_WelcomeOfferWeeklyText".localize() }
        
        static var notEligibleWelcomeOfferYearlyText: String { "Subscription_NotEligibleWelcomeOfferYearlyText".localize() }
        static var notEligibleWelcomeOfferMonthlyText: String { "Subscription_NotEligibleWelcomeOfferMonthlyText".localize() }
        static var notEligibleWelcomeOfferDailyText: String { "Subscription_NotEligibleWelcomeOfferDailyText".localize() }
        static var notEligibleWelcomeOfferWeeklyText: String { "Subscription_NotEligibleWelcomeOfferWeeklyText".localize() }
        
        static var yearlyThenText: String { "Subscription_YearlyThenText".localize() }
        static var monthlyThenText: String { "Subscription_MonthlyThenText".localize() }
        static var dailyThenText: String { "Subscription_DailyThenText".localize() }
        static var weeklyThenText: String { "Subscription_WeeklyThenText".localize() }
        
        static var yearlyJustText: String { "Subscription_YearlyJustText".localize() }
        
        static var yearlyPerText: String { "Subscription_YearlyPerText".localize() }
        static var monthlyPerText: String { "Subscription_MonthlyPerText".localize() }
        static var dailyPerText: String { "Subscription_DailyPerText".localize() }
        static var weeklyPerText: String { "Subscription_WeeklyPerText".localize() }
        
        static var periodDailyText: String { "Subscription_PeriodDailyText".localize() }
        static var periodMonthlyText: String { "Subscription_PeriodMonthlyText".localize() }
        static var periodWeeklyText: String { "Subscription_PeriodWeeklyText".localize() }
        static var periodYearlyText: String { "Subscription_PeriodYearlyText".localize() }
        
        static var singlePeriodDayText: String { "Subscription_SinglePeriodDayText".localize() }
        static var singlePeriodMonthText: String { "Subscription_SinglePeriodMonthText".localize() }
        static var singlePeriodWeekText: String { "Subscription_SinglePeriodWeekText".localize() }
        static var singlePeriodYearText: String { "Subscription_SinglePeriodYearText".localize() }
        
        static var freeTrialDay: String { "Subscription_FreeTrialDay".localize() }
        static var freeTrialMultipleDays: String { "Subscription_FreeTrialMultipleDay".localize() }
        static var freeTrialWeek: String { "Subscription_FreeTrialWeek".localize() }
        static var freeTrialMultipleWeeks: String { "Subscription_FreeTrialMultipleWeek".localize() }
        static var freeTrialMonth: String { "Subscription_FreeTrialMonth".localize() }
        static var freeTrialMultipleMonths: String { "Subscription_FreeTrialMultipleMonth".localize() }
        static var freeTrialYear: String { "Subscription_FreeTrialYear".localize() }
        static var freeTrialMultipleYears: String { "Subscription_FreeTrialMultipleYear".localize() }
        
        static var bestOfferBadgeLabel: String { "Subscription_Discount".localize() }
        
        static var dailyOfferOptionText: String { "Subscription_DailyOfferOptionText".localize() }
        static var weeklyOfferOptionText: String { "Subscription_WeeklyOfferOptionText".localize() }
        static var monthlyOfferOptionText: String { "Subscription_MonthlyOfferOptionText".localize() }
        static var yearlyOfferOptionText: String { "Subscription_YearlyOfferOptionText".localize() }
        
        static var noteligibleOption1: String { "Subscription_NotEligibleOption1".localize() }
        static var noteligibleOption2: String { "Subscription_NotEligibleOption2".localize() }
        
        static var priceTitleWithInitialBonus1: String { "Subscription_PriceTitleWithInitialBonus1".localize() }
        static var priceTitleWithInitialBonus2: String { "Subscription_PriceTitleWithInitialBonus2".localize() }
        
        static var subscriptionSuccess: String { "Subscription_SubscriptionSuccess".localize() }
        static var subscriptionCancelled: String { "Subscription_SubscriptionCancelled".localize() }
        static var subscriptionFailure: String { "Subscription_SubscriptionFailure".localize() }
        static var subscriptionStatusTitle: String { "Subscription_SubscriptionStatus".localize() }
        static var dismissOkeyButtonText: String { "Subscription_DismissOkeyButtonText".localize() }
        
        static var unlockButtonText: String { "Subscription_UnlockButtonText".localize() }
        static var tryForFreeText: String { "Subscription_TryForFreeText".localize() }
        static var cancelableInfoText: String { "Subscription_CancelableInfoText".localize() }
        
        static var subscriptionFirstIndexSubDescrtiption: String { "Subscription_FirstIndexSubDescrtiption".localize() }
        
        enum PromoOffer {
            static var navigationTitle: String { "PromoOffer_NavigationTitle".localize() }
            static var yearlyPlanDescription: String { "PromoOffer_YearlyPlanDescription".localize() }
            static var onlyOnceLabel: String { "PromoOffer_OnlyOnceLabel".localize() }
            static var priceFromLabel: String { "PromoOffer_PriceFromLabel".localize() }
            static var priceToLabel: String { "PromoOffer_PriceToLabel".localize() }
            static var claimOfferButtonLabel: String { "PromoOffer_ClaimOfferButtonLabel".localize() }
        }
        
        enum V2 {
            static var unlockPremiumLabel: String { "Subscription_V2_UnlockPremiumLabel".localize() }
            static var recurringCoinDescriptionLabel: String { "Subscription_V2_RecurringCoinDescriptionLabel".localize() }
        }
    }

    enum InternetConnection {
        static var checkYourInternetConnection: String { "InternetConnection_CheckYourInternetConnection".localize() }
    }
    
    enum Support {
        static let navigationTitle: String = "Support_NavigationTitle".localize()
        static let helpTitleLabel: String = "Support_HelpTitleLabel".localize()
        static let textFieldPlaceholder: String = "Support_TextFieldPlaceholder".localize()
        static let emptyTicketTitleLabel: String = "Support_EmptyTicketTitleLabel".localize()
        static let newChatButtonText: String = "Support_NewChatButtonText".localize()
    }
}
