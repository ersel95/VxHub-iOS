@_exported import VxHubCore
@_exported import VxHubRevenueCat
@_exported import VxHubFirebase

#if canImport(VxHubAmplitude)
@_exported import VxHubAmplitude
#endif

#if os(iOS)
#if canImport(VxHubAppsFlyer)
@_exported import VxHubAppsFlyer
#endif
#if canImport(VxHubOneSignal)
@_exported import VxHubOneSignal
#endif
#if canImport(VxHubFacebook)
@_exported import VxHubFacebook
#endif
#if canImport(VxHubBanner)
@_exported import VxHubBanner
#endif
#endif

#if canImport(VxHubGoogleSignIn)
@_exported import VxHubGoogleSignIn
#endif
#if canImport(VxHubSentry)
@_exported import VxHubSentry
#endif
#if canImport(VxHubMedia)
@_exported import VxHubMedia
#endif

extension VxHub {
    public static func registerAllProviders() {
        let registry = VxProviderRegistry.shared
        registry.purchaseProvider = VxRevenueCatProvider()

        #if canImport(VxHubAmplitude)
        registry.analyticsProvider = VxAmplitudeProvider()
        #endif

        #if os(iOS)
        #if canImport(VxHubAppsFlyer)
        registry.attributionProvider = VxAppsFlyerProvider()
        #endif
        #if canImport(VxHubOneSignal)
        registry.pushProvider = VxOneSignalProvider()
        #endif
        #if canImport(VxHubFacebook)
        registry.facebookProvider = VxFacebookProviderImpl()
        #endif
        #if canImport(VxHubBanner)
        registry.bannerProvider = VxBannerProviderImpl()
        #endif
        #endif

        registry.firebaseProvider = VxFirebaseProviderImpl()

        #if canImport(UIKit)
        #if canImport(VxHubGoogleSignIn)
        registry.googleSignInProvider = VxGoogleSignInProviderImpl()
        #endif
        #if canImport(VxHubMedia)
        registry.imageCachingProvider = VxSDWebImageProvider()
        registry.animationProvider = VxLottieProviderImpl()
        #endif
        #endif

        #if canImport(VxHubSentry)
        registry.crashReportingProvider = VxSentryProviderImpl()
        #endif
    }
}
