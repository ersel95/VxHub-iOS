//
//  File.swift
//  VxHub
//
//  Created by furkan on 2.01.2025.
//

import Foundation

public enum VxLocalizables {
    /// Copy for the ready-made authentication screens.
    public enum Auth {
        static public var signInTitle: String { "VxAuth_SignInTitle".localize(defaultValue: "Welcome back") }
        static public var signInSubtitle: String { "VxAuth_SignInSubtitle".localize(defaultValue: "Sign in to continue") }
        static public var signUpTitle: String { "VxAuth_SignUpTitle".localize(defaultValue: "Create your account") }
        static public var signUpSubtitle: String { "VxAuth_SignUpSubtitle".localize(defaultValue: "It only takes a moment") }
        static public var forgotTitle: String { "VxAuth_ForgotTitle".localize(defaultValue: "Reset your password") }
        static public var forgotSubtitle: String { "VxAuth_ForgotSubtitle".localize(defaultValue: "We will email you a code") }
        static public var codeTitle: String { "VxAuth_CodeTitle".localize(defaultValue: "Enter the code") }
        static public var codeSubtitle: String { "VxAuth_CodeSubtitle".localize(defaultValue: "We sent a 6-digit code to %@") }
        static public var newPasswordTitle: String { "VxAuth_NewPasswordTitle".localize(defaultValue: "Choose a new password") }
        static public var verifyTitle: String { "VxAuth_VerifyTitle".localize(defaultValue: "Confirm your email") }

        static public var emailPlaceholder: String { "VxAuth_EmailPlaceholder".localize(defaultValue: "Email") }
        static public var passwordPlaceholder: String { "VxAuth_PasswordPlaceholder".localize(defaultValue: "Password") }
        static public var namePlaceholder: String { "VxAuth_NamePlaceholder".localize(defaultValue: "Name (optional)") }
        static public var newPasswordPlaceholder: String { "VxAuth_NewPasswordPlaceholder".localize(defaultValue: "New password") }

        static public var signInButton: String { "VxAuth_SignInButton".localize(defaultValue: "Sign in") }
        static public var signUpButton: String { "VxAuth_SignUpButton".localize(defaultValue: "Create account") }
        static public var continueButton: String { "VxAuth_ContinueButton".localize(defaultValue: "Continue") }
        static public var sendCodeButton: String { "VxAuth_SendCodeButton".localize(defaultValue: "Send code") }
        static public var resendCodeButton: String { "VxAuth_ResendCodeButton".localize(defaultValue: "Send it again") }
        static public var savePasswordButton: String { "VxAuth_SavePasswordButton".localize(defaultValue: "Save password") }
        static public var googleButton: String { "VxAuth_GoogleButton".localize(defaultValue: "Continue with Google") }
        static public var appleButton: String { "VxAuth_AppleButton".localize(defaultValue: "Continue with Apple") }
        static public var guestButton: String { "VxAuth_GuestButton".localize(defaultValue: "Continue without an account") }

        static public var noAccountPrompt: String { "VxAuth_NoAccountPrompt".localize(defaultValue: "No account yet? Create one") }
        static public var hasAccountPrompt: String { "VxAuth_HasAccountPrompt".localize(defaultValue: "Already have an account? Sign in") }
        static public var forgotPrompt: String { "VxAuth_ForgotPrompt".localize(defaultValue: "Forgot your password?") }
        static public var separator: String { "VxAuth_Separator".localize(defaultValue: "or") }
        static public var legalNotice: String { "VxAuth_LegalNotice".localize(defaultValue: "By continuing you accept our Terms and Privacy Policy.") }

        // Errors are phrased as what to do next, not as what the server called it.
        static public var errorInvalidCredentials: String { "VxAuth_ErrorInvalidCredentials".localize(defaultValue: "That email and password do not match.") }
        static public var errorEmailTaken: String { "VxAuth_ErrorEmailTaken".localize(defaultValue: "An account with this email already exists.") }
        static public var errorInvalidCode: String { "VxAuth_ErrorInvalidCode".localize(defaultValue: "That code is not valid. Ask for a new one if it expired.") }
        static public var errorEmailNotVerified: String { "VxAuth_ErrorEmailNotVerified".localize(defaultValue: "Confirm your email address before signing in.") }
        static public var errorTooManyAttempts: String { "VxAuth_ErrorTooManyAttempts".localize(defaultValue: "Too many attempts. Try again in a minute.") }
        static public var errorPasswordTooShort: String { "VxAuth_ErrorPasswordTooShort".localize(defaultValue: "Use at least %d characters.") }
        static public var errorPasswordTooSimple: String { "VxAuth_ErrorPasswordTooSimple".localize(defaultValue: "Use both letters and numbers.") }
        static public var errorNetwork: String { "VxAuth_ErrorNetwork".localize(defaultValue: "No connection. Check your network and try again.") }
        static public var errorGeneric: String { "VxAuth_ErrorGeneric".localize(defaultValue: "Something went wrong. Please try again.") }

        static public var codeSent: String { "VxAuth_CodeSent".localize(defaultValue: "If that address has an account, a code is on its way.") }
        static public var changeEmailPrompt: String { "VxAuth_ChangeEmailPrompt".localize(defaultValue: "Wrong address? Change it") }
        static public var closeAccessibilityLabel: String { "VxAuth_Close".localize(defaultValue: "Close") }

        // Codes the API returns that a person can actually act on. Without these
        // a banned account, a project with sign-in switched off, and a genuine
        // server fault all read as "Something went wrong. Please try again." —
        // which tells the first two to keep trying at something that will never
        // work, and sends them to support.
        static public var errorAccountUnavailable: String { "VxAuth_ErrorAccountUnavailable".localize(defaultValue: "This account is no longer available. Contact support if you think this is a mistake.") }
        static public var errorSignInUnavailable: String { "VxAuth_ErrorSignInUnavailable".localize(defaultValue: "Signing in is turned off right now. Please try again later.") }
        static public var errorUsePasswordless: String { "VxAuth_ErrorUsePasswordless".localize(defaultValue: "This account signs in with Google or Apple. Use one of the buttons above.") }
        static public var errorProviderUnavailable: String { "VxAuth_ErrorProviderUnavailable".localize(defaultValue: "This sign-in method is unavailable right now. Try another one.") }
        static public var passwordChanged: String { "VxAuth_PasswordChanged".localize(defaultValue: "Your password has been changed.") }
    }

    public enum Permission {
        static public var microphoneAccessRequiredTitle: String { "VxPermissions_Default_MicrophoneAccessRequiredTitle".localize() }
        static public var microphoneAccessRequiredMessage: String { "VxPermissions_Default_MicrophoneAccessRequiredMessage".localize() }
        static public var microphoneAccessButtonTitle: String { "VxPermissions_Default_MicrophoneAccessButtonTitle".localize() }
        static public var cameraAccessRequiredTitle: String { "VxPermissions_Default_CameraAccessRequiredTitle".localize() }
        static public var cameraAccessRequiredMessage: String { "VxPermissions_Default_CameraAccessRequiredMessage".localize() }
        static public var cameraAccessButtonTitle: String { "VxPermissions_Default_CameraAccessButtonTitle".localize() }
        static public var settingsButtonTitle: String { "VxPermissions_Default_SettingsButtonTitle".localize() }
        static public var cancelButtonTitle: String { "VxPermissions_Default_CancelButtonTitle".localize() }
        static public var fileAccessRequiredTitle: String { "VxPermissions_Default_FileAccessRequiredTitle".localize() }
        static public var fileAccessRequiredMessage: String { "VxPermissions_Default_FileAccessRequiredMessage".localize() }
        static public var galleryAccessRequiredTitle: String { "VxPermissions_Default_GalleryAccessRequiredTitle".localize() }
        static public var galleryAccessRequiredMessage: String { "VxPermissions_Default_GalleryAccessRequiredMessage".localize() }
        static public var galleryAccessButtonTitle: String { "VxPermissions_Default_GalleryAccessButtonTitle".localize() }
        static public var photoLibraryAccessRequiredTitle: String { "VxPermissions_Default_PhotoLibraryAccessRequiredTitle".localize() }
        static public var photoLibraryAccessRequiredMessage: String { "VxPermissions_Default_PhotoLibraryAccessRequiredMessage".localize() }
        static public var photoLibraryAccessButtonTitle: String { "VxPermissions_Default_PhotoLibraryAccessButtonTitle".localize() }
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
        
        static var nothingToRestore: String { "Subscription_NothingToRestore".localize() }
        static var nothingToRestoreDescription: String { "Subscription_NothingToRestoreDescription".localize() }
        static var nothingToRestoreButtonLabel: String { "Subscription_NothingToRestoreButtonLabel".localize() }
        
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
            static var secureInfoLabel: String { "PromoOffer_SecureInfoLabel".localize() }
            
            static var discountTitle: String { "PromoOffer_DiscountTitle".localize() }
            static var discountAmountDescription: String { "PromoOffer_DiscountAmountDescription".localize() }
        }
        
        enum V2 {
            static var unlockPremiumLabel: String { "Subscription_V2_UnlockPremiumLabel".localize() }
            static var recurringCoinDescriptionLabel: String { "Subscription_V2_RecurringCoinDescriptionLabel".localize() }
        }

        enum V4 {
            static var ctaTrialLabel: String { "Subscription_V4_CTATrialLabel".localize() }
            static var ctaSubscribeLabel: String { "Subscription_V4_CTASubscribeLabel".localize() }
            static var trialIncludedLabel: String { "Subscription_V4_TrialIncludedLabel".localize() }
            static var perMonthLabel: String { "Subscription_V4_PerMonthLabel".localize() }
        }

        enum V3 {
            static var headlineLabel: String { "Subscription_V3_HeadlineLabel".localize() }
            static var subtitleLabel: String { "Subscription_V3_SubtitleLabel".localize() }
            static var tryFreeButtonLabel: String { "Subscription_V3_TryFreeButtonLabel".localize() }
            static var trustLineLabel: String { "Subscription_V3_TrustLineLabel".localize() }
            static var bestValueBadge: String { "Subscription_V3_BestValueBadge".localize() }
            static var freeForDaysLabel: String { "Subscription_V3_FreeForDaysLabel".localize() }
            static var thenPriceLabel: String { "Subscription_V3_ThenPriceLabel".localize() }
            static var perMonthLabel: String { "Subscription_V3_PerMonthLabel".localize() }
            static var ratingsLabel: String { "Subscription_V3_RatingsLabel".localize() }
        }
    }

    enum InternetConnection {
        static var checkYourInternetConnection: String { "InternetConnection_CheckYourInternetConnection".localize() }
        static var checkYourInternetConnectionDescription: String { "InternetConnection_CheckYourInternetConnectionDescription".localize() }
        static var checkYourInternetConnectionButtonLabel: String { "InternetConnection_CheckYourInternetConnectionButtonLabel".localize() }
    }
    
    enum Support {
        static var navigationTitle: String { "Support_NavigationTitle".localize() }
        static var helpTitleLabel: String { "Support_HelpTitleLabel".localize() }
        static var textFieldPlaceholder: String { "Support_TextFieldPlaceholder".localize() }
        static var emptyTicketTitleLabel: String { "Support_EmptyTicketTitleLabel".localize() }
        static var newChatButtonText: String { "Support_NewChatButtonText".localize() }
    }
}
