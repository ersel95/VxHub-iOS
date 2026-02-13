@_exported import VxHubCore
@_exported import VxHubRevenueCat
@_exported import VxHubAmplitude
#if os(iOS)
@_exported import VxHubAppsFlyer
@_exported import VxHubOneSignal
@_exported import VxHubFacebook
@_exported import VxHubBanner
#endif
@_exported import VxHubFirebase
@_exported import VxHubGoogleSignIn
@_exported import VxHubSentry
@_exported import VxHubMedia

extension VxHub {
    public static func registerAllProviders() {
        let registry = VxProviderRegistry.shared
        registry.purchaseProvider = VxRevenueCatProvider()
        registry.analyticsProvider = VxAmplitudeProvider()
        #if os(iOS)
        registry.attributionProvider = VxAppsFlyerProvider()
        registry.pushProvider = VxOneSignalProvider()
        registry.facebookProvider = VxFacebookProviderImpl()
        registry.bannerProvider = VxBannerProviderImpl()
        #endif
        registry.firebaseProvider = VxFirebaseProviderImpl()
        #if canImport(UIKit)
        registry.googleSignInProvider = VxGoogleSignInProviderImpl()
        registry.imageCachingProvider = VxSDWebImageProvider()
        registry.animationProvider = VxLottieProviderImpl()
        #endif
        registry.crashReportingProvider = VxSentryProviderImpl()
    }
}
