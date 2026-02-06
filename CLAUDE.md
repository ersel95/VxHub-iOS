# VxHub iOS SDK

Server-driven iOS monetization & engagement SDK. Wraps 13+ services (RevenueCat, Amplitude, OneSignal, AppsFlyer, Firebase, Sentry, etc.) under a single API. All 3rd-party API keys come from the backend — the only key you need is `hubId`.

- **Platform:** iOS 16+, Swift 6.0, Swift Package Manager
- **SPM URL:** `https://github.com/ersel95/VxHub-iOS.git`
- **Architecture:** Singleton (`VxHub.shared`) + server-driven config
- **Key concept:** Developer provides `hubId` → backend returns all 3rd-party keys & config at runtime

## Quick Start (SwiftUI + AppDelegate)

```swift
import SwiftUI
import VxHub

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let config = VxHubConfig(hubId: "YOUR_HUB_ID", environment: .prod, logLevel: .verbose)
        VxHub.shared.initialize(config: config, delegate: self, launchOptions: launchOptions, application: application)
        return true
    }

    // IMPORTANT: Warm start — call on every foreground return
    func applicationDidBecomeActive(_ application: UIApplication) {
        VxHub.shared.start()
    }
}

extension AppDelegate: VxHubDelegate {
    func vxHubDidInitialize() { /* SDK ready — products, localization, config loaded */ }
    func vxHubDidStart() { }
    func vxHubDidFailWithError(error: String?) { print("VxHub error: \(error ?? "unknown")") }
}
```

## Async/Await Quick Start

```swift
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Task {
            let config = VxHubConfig(hubId: "YOUR_HUB_ID", environment: .prod)
            let result = try await VxHub.shared.initialize(
                config: config, delegate: self, launchOptions: launchOptions, application: application)
            switch result {
            case .success: print("SDK ready")
            case .banned: print("Device banned")
            case .forceUpdateRequired: print("Update required")
            }
        }
        return true
    }
}
```

## Info.plist Requirements

```xml
<!-- ATT (required if requestAtt: true) -->
<key>NSUserTrackingUsageDescription</key>
<string>We use this to provide personalized ads</string>

<!-- Google Sign-In URL Scheme (REVERSED_CLIENT_ID from GoogleService-Info.plist) -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_ID</string>
        </array>
    </dict>
</array>

<!-- App detection (canOpenURL) -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>instagram</string>
    <string>twitter</string>
    <string>tiktok</string>
    <string>snapchat</string>
    <string>whatsapp</string>
    <string>telegram</string>
    <string>fb</string>
    <string>pinterest</string>
</array>
```

## Public API Index

### Initialization & Lifecycle
- `VxHub.shared.initialize(config:delegate:launchOptions:application:)` — cold start
- `VxHub.shared.initialize(config:delegate:sceneOptions:)` — scene-based cold start
- `VxHub.shared.start(restoreTransactions:completion:)` — warm start (call in applicationDidBecomeActive)
- `async initialize(config:delegate:launchOptions:application:) -> VxHubInitResult` — async cold start
- `async start(restoreTransactions:) -> Bool` — async warm start

### Properties
- `isPremium: Bool` — current subscription status
- `balance: Int` — user coin balance
- `revenueCatProducts: [VxStoreProduct]` — available products (populated after init)
- `deviceInfo: VxDeviceInfo?` — server response data
- `remoteConfig: [String: Any]` — remote config dictionary
- `isConnectedToInternet: Bool` — network status
- `preferredLanguage: String?` — current language code
- `supportedLanguages: [String]` — backend-defined languages
- `appStoreId: String` — App Store ID from backend

### Purchases
- `purchase(_ product: StoreProduct, completion:)` — buy a product
- `restorePurchases(completion:)` — restore purchases
- `getRevenueCatPremiumState(completion:)` — check live premium status
- `saveNonConsumablePurchase(productIdentifier:)` — persist non-consumable

### Paywall & Promo
- `showMainPaywall(from:configuration:presentationStyle:completion:onRestoreStateChange:onReedemCodeButtonTapped:)` — show paywall
- `showPromoOffer(from:productIdentifier:productToCompareIdentifier:presentationStyle:type:completion:)` — show promo

### Authentication
- `signInWithGoogle(presenting:completion:)` — Google Sign-In
- `signInWithApple(presenting:completion:)` — Apple Sign-In
- `handleLogout(completion:)` — logout across all services
- `deleteAccount(completion:)` — delete user account

### Support
- `showContactUs(from:configuration:)` — show support UI
- `getTicketsUnseenStatus(completion:)` — check unread tickets

### Analytics
- `logAmplitudeEvent(eventName:properties:)` — log Amplitude event
- `logAppsFlyerEvent(eventName:values:)` — log AppsFlyer event
- `getVariantPayload(for:) -> [String: Any]?` — A/B test variant

### Media
- `downloadImage(from:isLocalized:completion:)` — download image
- `getDownloadedImage(from:isLocalized:completion:)` — get cached UIImage or SwiftUI Image
- `downloadVideo(from:completion:)` / `getDownloadedVideoPath(from:) -> URL?`
- `vxSetImage(on:with:...)` — SDWebImage wrapper for UIImageView
- `createAndPlayAnimation(name:in:tag:...)` — Lottie playback
- `downloadLottieAnimation(from:completion:)` — download Lottie JSON
- `compressImage(_:maxDimension:quality:maxSize:) -> UIImage`

### Utility
- `showEula(isFullScreen:showCloseButton:)` / `showPrivacy(...)` — legal pages
- `presentWebUrl(url:isFullScreen:showCloseButton:)` — open URL in-app
- `requestReview()` — smart App Store review prompt
- `changePreferredLanguage(to:completion:)` — switch language
- `showBanner(_:type:font:buttonLabel:action:)` — in-app notification banner
- `requestAttPerm()` — trigger ATT dialog
- `usePromoCode(_:completion:)` — validate promo code
- `validateQrCode(token:completion:)` — QR login
- `claimRetentionCoinGift(completion:)` / `markRetentionCoinAsGiven()` / `hasGivenRetentionCoin()`
- `setupReachability()` / `resetReachability()` / `killReachability()`
- `startSentry(dsn:config:)` / `stopSentry()`
- `configureDeviceInset()`

## Key Types
- `VxHubConfig` — SDK configuration (hubId, environment, logLevel, requestAtt)
- `VxHubDelegate` — callback protocol (required: didInitialize, didStart, didFailWithError)
- `VxHubInitResult` — async init result (.success, .banned, .forceUpdateRequired)
- `VxHubError` — typed errors for async API
- `VxMainPaywallConfiguration` — paywall UI config
- `VxSupportConfiguration` — support UI theme (30+ color params, all with defaults)
- `VxStoreProduct` — product with eligibility & bonus info
- `VxBannerTypes` — .success, .error, .warning, .info, .debug
- `VxFont` — .rounded, .system(name), .custom(name)

## Important Notes
- **Server-driven:** No hardcoded API keys. Backend returns RevenueCat, Amplitude, OneSignal, AppsFlyer, Firebase, Sentry keys based on `hubId`.
- **Warm start required:** Call `VxHub.shared.start()` in `applicationDidBecomeActive` to re-register device.
- **Products available after init:** `revenueCatProducts` is empty until `vxHubDidInitialize()` fires.
- **UIKit-based UI:** Paywall and Support are UIKit ViewControllers. Use `UIViewControllerRepresentable` for SwiftUI.
- **GoogleService-Info.plist:** Downloaded automatically from backend — do NOT bundle manually.

## Detailed Documentation
- [Integration Guide](docs/integration-guide.md) — step-by-step with full code examples
- [API Reference](docs/api-reference.md) — complete method signatures and types
- [Troubleshooting](docs/troubleshooting.md) — common issues and fixes
