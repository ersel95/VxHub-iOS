import Foundation

public final class VxProviderRegistry: @unchecked Sendable {
    public static let shared = VxProviderRegistry()
    private init() {}

    public var purchaseProvider: (any VxPurchaseProvider)?
    public var analyticsProvider: (any VxAnalyticsProvider)?
    public var attributionProvider: (any VxAttributionProvider)?
    public var firebaseProvider: (any VxFirebaseProvider)?
    public var crashReportingProvider: (any VxCrashReportingProvider)?

    #if os(iOS)
    public var pushProvider: (any VxPushProvider)?
    public var facebookProvider: (any VxFacebookProvider)?
    public var bannerProvider: (any VxBannerProvider)?
    #endif

    #if canImport(UIKit)
    public var googleSignInProvider: (any VxGoogleSignInProvider)?
    public var imageCachingProvider: (any VxImageCachingProvider)?
    public var animationProvider: (any VxAnimationProvider)?
    #endif

    public func autoRegister() {
        let registrars = [
            "VxRevenueCatRegistrar",
            "VxFirebaseRegistrar",
            "VxAmplitudeRegistrar",
            "VxAppsFlyerRegistrar",
            "VxOneSignalRegistrar",
            "VxFacebookRegistrar",
            "VxSentryRegistrar",
            "VxGoogleSignInRegistrar",
            "VxMediaRegistrar",
            "VxBannerRegistrar",
        ]
        for name in registrars {
            guard let cls = NSClassFromString(name) else { continue }
            let sel = NSSelectorFromString("register")
            guard cls.responds(to: sel) else { continue }
            _ = (cls as AnyObject).perform(sel)
        }
    }
}
