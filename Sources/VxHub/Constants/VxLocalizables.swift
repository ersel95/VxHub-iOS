//
//  File.swift
//  VxHub
//
//  Created by furkan on 2.01.2025.
//

import Foundation

public enum VxLocalizables {
    public enum Permission {
        static public let microphoneAccessRequiredTitle = VxLocalizer.shared.localize("VxPermissions_Default_MicrophoneAccessRequiredTitle")
        static public let microphoneAccessRequiredMessage = VxLocalizer.shared.localize("VxPermissions_Default_MicrophoneAccessRequiredMessage")
        static public let microphoneAccessButtonTitle = VxLocalizer.shared.localize("VxPermissions_Default_MicrophoneAccessButtonTitle")
        static public let cameraAccessRequiredTitle = VxLocalizer.shared.localize("VxPermissions_Default_CameraAccessRequiredTitle")
        static public let cameraAccessRequiredMessage = VxLocalizer.shared.localize("VxPermissions_Default_CameraAccessRequiredMessage")
        static public let cameraAccessButtonTitle = VxLocalizer.shared.localize("VxPermissions_Default_CameraAccessButtonTitle")
        static public let settingsButtonTitle = VxLocalizer.shared.localize("VxPermissions_Default_SettingsButtonTitle")
        static public let cancelButtonTitle = VxLocalizer.shared.localize("VxPermissions_Default_CancelButtonTitle")
        static public let fileAccessRequiredTitle = VxLocalizer.shared.localize("VxPermissions_Default_FileAccessRequiredTitle")
        static public let fileAccessRequiredMessage = VxLocalizer.shared.localize("VxPermissions_Default_FileAccessRequiredMessage")
        static public let galleryAccessRequiredTitle = VxLocalizer.shared.localize("VxPermissions_Default_GalleryAccessRequiredTitle")
        static public let galleryAccessRequiredMessage = VxLocalizer.shared.localize("VxPermissions_Default_GalleryAccessRequiredMessage")
        static public let galleryAccessButtonTitle = VxLocalizer.shared.localize("VxPermissions_Default_GalleryAccessButtonTitle")
        static public let photoLibraryAccessRequiredTitle = VxLocalizer.shared.localize("VxPermissions_Default_PhotoLibraryAccessRequiredTitle")
        static public let photoLibraryAccessRequiredMessage = VxLocalizer.shared.localize("VxPermissions_Default_PhotoLibraryAccessRequiredMessage")
        static public let photoLibraryAccessButtonTitle = VxLocalizer.shared.localize("VxPermissions_Default_PhotoLibraryAccessButtonTitle")
    }
    
    enum Subscription {
        static var subscribeButtonLabel : String { VxLocalizer.shared.localize("Subscription_SubscribeButtonLabel") } // SUBSCRIBE (Button text)
        static var restorePurchaseLabel : String { VxLocalizer.shared.localize("Subscription_RestorePurchase") } // Restore Purchase
        static var termsOfUse : String { VxLocalizer.shared.localize("Subscription_TermsOfUse") } // Terms of Use
        static var privacyPol : String { VxLocalizer.shared.localize("Subscription_PrivacyPol") } //  Privacy Policy
        
        static var headerBodyText: String { VxLocalizer.shared.localize("Subscription_HeaderBodyText") } // 10+ millions
        static var freeTrailEnabledLabel: String { VxLocalizer.shared.localize("Subscription_FreeTrailEnabledLabel") }
        
        static var welcomeOfferYearlyText : String { VxLocalizer.shared.localize("Subscription_WelcomeOfferYearlyText") } // Welcome Offer {xxxfreeTrial} days free trial and {xxxprice} per year }
        static var welcomeOfferMonthlyText : String { VxLocalizer.shared.localize("Subscription_WelcomeOfferMonthlyText") } // Welcome Offer {xxxfreeTrial} days free trial and {xxxprice} per month }
        static var welcomeOfferDailyText : String { VxLocalizer.shared.localize("Subscription_WelcomeOfferDailyText") } // Welcome Offer {xxxfreeTrial} days free trial and {xxxprice} per day }
        static var welcomeOfferWeeklyText : String { VxLocalizer.shared.localize("Subscription_WelcomeOfferWeeklyText") } // Welcome Offer {xxxfreeTrial} days free trial and {xxxprice} per week }
        
        static var notEligibleWelcomeOfferYearlyText : String { VxLocalizer.shared.localize("Subscription_NotEligibleWelcomeOfferYearlyText") } // Welcome Offer not availble free trial and {xxxprice} per year }
        static var notEligibleWelcomeOfferMonthlyText : String { VxLocalizer.shared.localize("Subscription_NotEligibleWelcomeOfferMonthlyText") }
        static var notEligibleWelcomeOfferDailyText : String { VxLocalizer.shared.localize("Subscription_NotEligibleWelcomeOfferDailyText") }
        static var notEligibleWelcomeOfferWeeklyText : String { VxLocalizer.shared.localize("Subscription_NotEligibleWelcomeOfferWeeklyText") }
        
        static var yearlyThenText: String { VxLocalizer.shared.localize("Subscription_YearlyThenText") } // yearly then
        static var monthlyThenText: String { VxLocalizer.shared.localize("Subscription_MonthlyThenText") } // monthly then
        static var dailyThenText: String { VxLocalizer.shared.localize("Subscription_DailyThenText") } // daily then
        static var weeklyThenText: String { VxLocalizer.shared.localize("Subscription_WeeklyThenText") } // weekly then
        
        static var yearlyJustText: String { VxLocalizer.shared.localize("Subscription_YearlyJustText") } // just
        
        static var yearlyPerText: String { VxLocalizer.shared.localize("Subscription_YearlyPerText") } // per year
        static var monthlyPerText: String { VxLocalizer.shared.localize("Subscription_MonthlyPerText") } // per mont
        static var dailyPerText: String { VxLocalizer.shared.localize("Subscription_DailyPerText") } // per daily
        static var weeklyPerText: String { VxLocalizer.shared.localize("Subscription_WeeklyPerText") } // per week
        
        static var periodDailyText: String { VxLocalizer.shared.localize("Subscription_PeriodDailyText") } // Daily
        static var periodMonthlyText: String { VxLocalizer.shared.localize("Subscription_PeriodMonthlyText") } // Monthly
        static var periodWeeklyText: String { VxLocalizer.shared.localize("Subscription_PeriodWeeklyText") } // Weekly
        static var periodYearlyText: String { VxLocalizer.shared.localize("Subscription_PeriodYearlyText") } // Yearly
        
        
        static var freeTrialDay : String { VxLocalizer.shared.localize("Subscription_FreeTrialDay") } // Day
        static var freeTrialMultipleDays : String { VxLocalizer.shared.localize("Subscription_FreeTrialMultipleDay") } // Days

        static var freeTrialWeek : String { VxLocalizer.shared.localize("Subscription_FreeTrialWeek") } // Week
        static var freeTrialMultipleWeeks : String { VxLocalizer.shared.localize("Subscription_FreeTrialMultipleWeek") } // Weeks

        static var freeTrialMonth : String { VxLocalizer.shared.localize("Subscription_FreeTrialMonth") } // Month
        static var freeTrialMultipleMonths : String { VxLocalizer.shared.localize("Subscription_FreeTrialMultipleMonth") } // Months

        static var freeTrialYear : String { VxLocalizer.shared.localize("Subscription_FreeTrialYear") } // Year
        static var freeTrialMultipleYears : String { VxLocalizer.shared.localize("Subscription_FreeTrialMultipleYear") } // Years
                
        static var discountAmountLabel: String { VxLocalizer.shared.localize("Subscription_Discount") }
        
        static var dailyOfferOptionText: String { VxLocalizer.shared.localize("Subscription_DailyOfferOptionText") } // {xxxfreeTrial} free trial
        static var weeklyOfferOptionText: String { VxLocalizer.shared.localize("Subscription_WeeklyOfferOptionText") } // {xxxfreeTrial} free trial
        static var monthlyOfferOptionText: String { VxLocalizer.shared.localize("Subscription_MonthlyOfferOptionText") } // {xxxfreeTrial} free trial
        static var yearlyOfferOptionText: String { VxLocalizer.shared.localize("Subscription_YearlyOfferOptionText") } //{xxxfreeTrial} free trial
        
        static var noteligibleOption1: String { VxLocalizer.shared.localize("Subscription_NotEligibleOption1") } //"{xxxsubPeriod} Offer"
        static var noteligibleOption2: String { VxLocalizer.shared.localize("Subscription_NotEligibleOption2") } //"{xxxsubPeriod} Offer"

        static var subscriptionSuccess: String { VxLocalizer.shared.localize("Subscription_SubscriptionSuccess") } // "Aboneliğiniz Geri Yüklendi"
        static var subscriptionCancelled: String { VxLocalizer.shared.localize("Subscription_SubscriptionCancelled") } // "Aboneliğiniz Zaten var & Işlem iptal edildi"
        static var subscriptionFailure: String { VxLocalizer.shared.localize("Subscription_SubscriptionFailure") } // "Mevcut Aboneliğiniz Bulunamadı"
        static var subscriptionStatusTitle: String { VxLocalizer.shared.localize("Subscription_SubscriptionStatus") } // "Subscription Status"
        static var dismissOkeyButtonText: String { VxLocalizer.shared.localize("Subscription_DismissOkeyButtonText") }
        
        static var unlockButtonText: String { VxLocalizer.shared.localize("Subscription_UnlockButtonText") }
        static var tryForFreeText: String { VxLocalizer.shared.localize("Subscription_TryForFreeText") }
        static var cancelableInfoText: String { VxLocalizer.shared.localize("Subscription_CancelableInfoText") }
        
        static var subscriptionFirstIndexSubDescrtiption : String { VxLocalizer.shared.localize("Subscription_FirstIndexSubDescrtiption") }
    }
}
