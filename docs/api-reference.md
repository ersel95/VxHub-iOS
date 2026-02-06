# VxHub iOS SDK — API Reference

Complete reference for all public properties, methods, and types.

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `shared` | `VxHub` (static) | Singleton instance |
| `config` | `VxHubConfig?` | Current SDK configuration |
| `deviceInfo` | `VxDeviceInfo?` | Server response: device profile, app config, 3rd party info |
| `deviceConfig` | `VxDeviceConfig?` | Local device info (OS, model, UDID) |
| `remoteConfig` | `[String: Any]` | Remote config dictionary from backend |
| `isPremium` | `Bool` | Current subscription status (synced at init & purchase) |
| `balance` | `Int` | User's coin balance |
| `revenueCatProducts` | `[VxStoreProduct]` | Available products (populated after init) |
| `isConnectedToInternet` | `Bool` | Network connectivity status |
| `currentConnectionType` | `String` | "WiFi", "Cellular", or "No Connection" |
| `preferredLanguage` | `String?` | Current language code (e.g. "en") |
| `supportedLanguages` | `[String]` | Backend-defined supported languages |
| `appStoreId` | `String` | App Store app ID from backend |
| `deviceBottomHeight` | `CGFloat?` | Bottom safe area inset (call `configureDeviceInset()` first) |

## Methods — Initialization & Lifecycle

| Method | Returns | Description |
|--------|---------|-------------|
| `initialize(config:delegate:launchOptions:application:)` | `Void` | Cold start with UIApplication (AppDelegate) |
| `initialize(config:delegate:sceneOptions:)` | `Void` | Cold start with scene options (SceneDelegate) |
| `start(restoreTransactions:completion:)` | `Void` | Warm start — call in `applicationDidBecomeActive` |
| `initialize(config:delegate:launchOptions:application:)` async | `VxHubInitResult` | Async cold start |
| `start(restoreTransactions:)` async | `Bool` | Async warm start |

## Methods — Purchases

| Method | Returns | Description |
|--------|---------|-------------|
| `purchase(_ product: StoreProduct, completion:)` | `Void` | Purchase a product |
| `purchase(_ product: StoreProduct)` async | `Bool` | Async purchase |
| `restorePurchases(completion:)` | `Void` | Restore purchases. Callback: `(hasSubscription, hasNonConsumable, error?)` |
| `restorePurchases()` async | `(Bool, Bool, String?)` | Async restore |
| `getRevenueCatPremiumState(completion:)` | `Void` | Live premium check from RevenueCat |
| `getRevenueCatPremiumState()` async | `Bool` | Async live premium check |
| `saveNonConsumablePurchase(productIdentifier:)` | `Void` | Persist non-consumable purchase in keychain |
| `getProducts()` | `Void` | Fetch products from network (internal use) |

## Methods — Paywall

| Method | Returns | Description |
|--------|---------|-------------|
| `showMainPaywall(from:configuration:presentationStyle:completion:onRestoreStateChange:onReedemCodeButtonTapped:)` | `Void` | Show paywall. `completion: (Bool, String?) -> Void` — (didPurchase, productIdentifier) |
| `showPromoOffer(from:productIdentifier:productToCompareIdentifier:presentationStyle:type:completion:)` | `Void` | Show promo offer paywall |

## Methods — Authentication

| Method | Returns | Description |
|--------|---------|-------------|
| `signInWithGoogle(presenting:completion:)` | `Void` | Google Sign-In. Callback: `(Bool?, Error?)` |
| `signInWithGoogle(presenting:)` async | `Bool` | Async Google Sign-In |
| `signInWithApple(presenting:completion:)` | `Void` | Apple Sign-In. Callback: `(Bool?, Error?)` |
| `signInWithApple(presenting:)` async | `Bool` | Async Apple Sign-In |
| `handleLogout(completion:)` | `Void` | Logout from all services. Callback: `(CustomerInfo?, Bool)` |
| `handleLogout()` async | `(CustomerInfo?, Bool)` | Async logout |
| `deleteAccount(completion:)` | `Void` | Delete account. Callback: `(Bool, String?)` |
| `deleteAccount()` async | `(Bool, String?)` | Async delete account |

## Methods — Support

| Method | Returns | Description |
|--------|---------|-------------|
| `showContactUs(from:configuration:)` | `Void` | Push support VC onto nav stack. VC must be in UINavigationController |
| `getTicketsUnseenStatus(completion:)` | `Void` | Check for unread tickets. Callback: `(Bool, String?)` |
| `getTicketsUnseenStatus()` async | `(Bool, String?)` | Async unseen check |

## Methods — Media (Images)

| Method | Returns | Description |
|--------|---------|-------------|
| `downloadImage(from:isLocalized:completion:)` | `Void` | Download & cache image |
| `downloadImage(from:isLocalized:)` async | `Void` | Async download |
| `downloadImages(from:isLocalized:completion:)` | `Void` | Batch download. Returns successfully downloaded URLs |
| `downloadImages(from:isLocalized:)` async | `[String]` | Async batch download |
| `getDownloadedImage(from:isLocalized:completion:)` | `Void` | Get cached UIImage |
| `getDownloadedImage(from:isLocalized:completion:)` | `Void` | Get cached SwiftUI Image (overloaded) |
| `getDownloadedImage(from:isLocalized:)` async | `UIImage?` | Async get UIImage |
| `getDownloadedImage(from:isLocalized:)` async | `Image?` | Async get SwiftUI Image |
| `getImages(from:isLocalized:completion:)` | `Void` | Get multiple cached UIImages |
| `getImages(from:isLocalized:completion:)` | `Void` | Get multiple cached SwiftUI Images (overloaded) |
| `getImages(from:isLocalized:)` async | `[UIImage]` | Async get UIImages |
| `getImages(from:isLocalized:)` async | `[Image]` | Async get SwiftUI Images |
| `vxSetImage(on:with:activityIndicatorTintColor:placeholderImage:showLoadingIndicator:indicatorSize:completion:)` | `Void` | SDWebImage wrapper for UIImageView |
| `compressImage(_:maxDimension:quality:maxSize:)` | `UIImage` | Compress image (default: max 2048px, 2MB) |
| `isDownloaded(url:)` | `Bool` | Check if URL content is cached |

## Methods — Media (Video)

| Method | Returns | Description |
|--------|---------|-------------|
| `downloadVideo(from:completion:)` | `Void` | Download video |
| `downloadVideo(from:)` async | `Void` | Async download |
| `getDownloadedVideoPath(from:)` | `URL?` | Get local file path for downloaded video |

## Methods — Media (Lottie)

| Method | Returns | Description |
|--------|---------|-------------|
| `createAndPlayAnimation(name:in:tag:removeOnFinish:loopAnimation:animationSpeed:contentMode:completion:)` | `Void` | Play Lottie animation in view |
| `downloadLottieAnimation(from:completion:)` | `Void` | Download Lottie JSON file |
| `downloadLottieAnimation(from:)` async | `Void` | Async download |
| `stopAnimation(with:)` | `Void` | Stop animation by tag |
| `stopAllAnimations()` | `Void` | Stop all animations |
| `removeAnimation(with:)` | `Void` | Remove animation view by tag |
| `removeAllAnimations()` | `Void` | Remove all animation views |

## Methods — Analytics

| Method | Returns | Description |
|--------|---------|-------------|
| `logAmplitudeEvent(eventName:properties:)` | `Void` | Log Amplitude event |
| `logAppsFlyerEvent(eventName:values:)` | `Void` | Log AppsFlyer event |
| `getVariantPayload(for:)` | `[String: Any]?` | Get A/B test variant payload |

## Methods — Utility

| Method | Returns | Description |
|--------|---------|-------------|
| `showEula(isFullScreen:showCloseButton:)` | `Void` | Show EULA web page |
| `showPrivacy(isFullScreen:showCloseButton:)` | `Void` | Show privacy policy web page |
| `presentWebUrl(url:isFullScreen:showCloseButton:)` | `Void` | Open URL in in-app web viewer |
| `requestReview()` | `Void` | Smart review prompt (in-app → App Store) |
| `changePreferredLanguage(to:completion:)` | `Void` | Change language, re-download localizables |
| `changePreferredLanguage(to:)` async | `Bool` | Async change language |
| `showBanner(_:type:font:buttonLabel:action:)` | `Void` | Show in-app notification banner |
| `requestAttPerm()` | `Void` | Request ATT permission |
| `getIDFA()` | `String?` | Get IDFA if permitted |
| `isSimulator()` | `Bool` | Check if running on simulator |
| `configureDeviceInset()` | `Void` | Calculate device bottom safe area |
| `setupReachability()` | `Void` | Start network monitoring |
| `resetReachability()` | `Void` | Reset and restart network monitoring |
| `killReachability()` | `Void` | Stop network monitoring |
| `buildConfigValue(for:)` | `String?` | Read build configuration value |
| `openFbUrlIfNeeded(url:)` | `Void` | Handle Facebook deep link URL |
| `startSentry(dsn:config:)` | `Void` | Start Sentry crash reporting |
| `stopSentry()` | `Void` | Stop Sentry |

## Methods — Promo & QR

| Method | Returns | Description |
|--------|---------|-------------|
| `usePromoCode(_:completion:)` | `Void` | Validate promo code. Returns `VxPromoCode` |
| `usePromoCode(_:)` async | `VxPromoCode` | Async validate |
| `validateQrCode(token:completion:)` | `Void` | Approve QR login. Callback: `(Bool, String?)` |
| `validateQrCode(token:)` async | `(Bool, String?)` | Async QR validation |

## Methods — Retention Coins

| Method | Returns | Description |
|--------|---------|-------------|
| `claimRetentionCoinGift(completion:)` | `Void` | Claim daily coin gift. Returns `VxClaimRetentionCoinGiftResponse?` |
| `claimRetentionCoinGift()` async | `VxClaimRetentionCoinGiftResponse` | Async claim |
| `markRetentionCoinAsGiven()` | `Void` | Mark gift as claimed in keychain |
| `hasGivenRetentionCoin()` | `Bool` | Check if gift already claimed |

---

## Types

### VxHubConfig

```swift
public struct VxHubConfig {
    public init(
        hubId: String,
        environment: VxHubEnvironment = .prod,    // .prod | .stage
        appLifecycle: VxHubAppLifecycle = .appDelegate, // .appDelegate | .sceneDelegate
        responseQueue: DispatchQueue = .main,
        requestAtt: Bool = false,
        googlePlistFileName: String = "GoogleService-Info",
        logLevel: LogLevel = .verbose              // .verbose | .debug | .info | .warning | .error
    )

    // Convenience init — prod defaults with ATT enabled
    public init(hubId: String)
}
```

### VxHubDelegate

```swift
@objc public protocol VxHubDelegate: AnyObject {
    // Required
    func vxHubDidInitialize()
    func vxHubDidStart()
    func vxHubDidFailWithError(error: String?)

    // Optional
    @objc optional func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any])
    @objc optional func onConversionDataFail(_ error: Error)
    @objc optional func oneSignalDidReceiveNotification(_ info: [String: Any])
    @objc optional func vxHubDidReceiveForceUpdate()
    @objc optional func vxHubDidReceiveBanned()
    @objc optional func onPurchaseComplete(didSucceed: Bool, error: String?)
    @objc optional func onRestorePurchases(didSucceed: Bool, error: String?)
    @objc optional func onFetchProducts(products: [StoreProduct]?, error: String?)
    @objc optional func vxHubDidChangeNetworkStatus(isConnected: Bool, connectionType: String)
}
```

### VxHubInitResult

```swift
public enum VxHubInitResult: Sendable {
    case success
    case banned
    case forceUpdateRequired
}
```

### VxHubError

```swift
public enum VxHubError: Error, Sendable, LocalizedError {
    case networkUnavailable
    case requestFailed(statusCode: Int)
    case noData
    case decodingFailed(underlying: Error)
    case invalidURL(String)
    case purchaseFailed(reason: String?)
    case signInFailed(provider: String, reason: String)
    case promoCodeInvalid(messages: [String])
    case unknown(String)
}
```

### VxMainPaywallConfiguration

```swift
public struct VxMainPaywallConfiguration: @unchecked Sendable {
    public init(
        paywallType: Int,                                   // VxMainPaywallTypes.v1.rawValue or .v2
        font: VxFont = .rounded,
        appLogoImageName: String,                           // asset catalog name
        appNameImageName: String?,                          // optional app name image
        descriptionFont: VxFont,
        descriptionItems: [(image: String, text: String)],  // feature list
        mainButtonColor: UIColor = .purple,
        backgroundColor: UIColor = .white,
        backgroundImageName: String? = nil,
        videoBundleName: String? = nil,                     // bundle video name
        videoHeightMultiplier: CGFloat = 0.72,
        showGradientVideoBackground: Bool = false,
        isLightMode: Bool = true,
        textColor: UIColor? = nil,                          // defaults based on isLightMode
        analyticsEvents: [AnalyticEvents]? = nil,           // [.select, .purchased]
        dismissButtonColor: UIColor? = nil,
        isCloseButtonEnabled: Bool = false,
        closeButtonColor: UIColor = .blue
    )
}
```

### VxMainPaywallTypes

```swift
public enum VxMainPaywallTypes: Int {
    case v1     // 0
    case v2     // 1
}
```

### VxPaywallPresentationStyle

```swift
public enum VxPaywallPresentationStyle: Int {
    case present  // 0 — modal presentation
    case push     // 1 — navigation push
}
```

### VxSupportConfiguration

```swift
public struct VxSupportConfiguration: @unchecked Sendable {
    public init(
        font: VxFont = .rounded,
        backgroundColor: UIColor = .dynamicColor(light: .white, dark: .black),
        navigationTintColor: UIColor = ...,
        listingActionColor: UIColor = ...,
        listingActionTextColor: UIColor = ...,
        listingItemTitleColor: UIColor = ...,
        listingDescriptionColor: UIColor = ...,
        listingDateColor: UIColor = ...,
        listingUnreadColor: UIColor = ...,
        detailAdminTicketBorderColor: UIColor = ...,
        detailAdminTicketBackgroundColor: UIColor = ...,
        detailAdminTicketMessageColor: UIColor = ...,
        detailAdminTicketDateColor: UIColor = ...,
        detailUserTicketBackgroundColor: UIColor = ...,
        detailUserTicketMessageColor: UIColor = ...,
        detailUserTicketDateColor: UIColor = ...,
        detailSendButtonActiveImage: UIImage? = nil,
        detailPlaceholderColor: UIColor = ...,
        detailHelpImage: UIImage? = nil,
        detailHelpColor: UIColor = ...,
        ticketSheetBackgroundColor: UIColor = ...,
        ticketSheetTextColor: UIColor = ...,
        ticketSheetLineColor: UIColor = ...,
        ticketSheetShadowColor: UIColor = ...,
        messageTextFieldBackgroundColor: UIColor = ...,
        messageTextFieldTextColor: UIColor = ...,
        headerLineViewColor: UIColor = ...,
        bottomLineViewColor: UIColor = ...,
        messageBarBackgroundColor: UIColor = ...
    )
    // All parameters have sensible light/dark mode defaults.
    // Pass VxSupportConfiguration() for default theme.
}
```

### VxStoreProduct

```swift
public struct VxStoreProduct {
    public let storeProduct: StoreProduct          // RevenueCat StoreProduct
    public let isDiscountOrTrialEligible: Bool     // trial/intro offer eligible
    public let initialBonus: Int?                  // coins on first purchase
    public let renewalBonus: Int?                  // coins on renewal
    public let vxProductType: VxProductType?
}
```

### VxProductType

```swift
public enum VxProductType: Int {
    case consumable              // 0
    case nonConsumable           // 1
    case nonRenewalSubscription  // 2
    case renewalSubscription     // 3
}
```

### VxPromoCode

```swift
public struct VxPromoCode: Codable, Sendable {
    public let error: VxPromoCodeErrorResponse?
    public let data: VxPromoCodeData?
}

public struct VxPromoCodeErrorResponse: Codable, Sendable {
    public let message: [String]?
}

public struct VxPromoCodeData: Codable, Sendable {
    public let actionType: VxPromoCodeActionTypes?  // .discount | .premium | .coin
    public let actionMeta: VxPromoCodeActionMeta?
    public let extraData: [String: String]?
}

public struct VxPromoCodeActionMeta: Codable, Sendable {
    public var packageName: String?     // for .discount
    public var durationInDays: Int?     // for .premium
    public var coinAmount: Int?         // for .coin
}

public enum VxPromoCodeActionTypes: String, Codable, Sendable {
    case discount, premium, coin
}
```

### VxClaimRetentionCoinGiftResponse

```swift
public struct VxClaimRetentionCoinGiftResponse: Codable {
    public let status: String?
    public let giftAmount: Int?       // JSON key: "gift_amount"
}
```

### VxBannerTypes

```swift
public enum VxBannerTypes: Sendable {
    case success    // green
    case error      // red
    case warning    // yellow
    case info       // blue
    case debug      // black
}
```

### VxFont

```swift
public enum VxFont: @unchecked Sendable {
    case system(String)     // system font by name
    case custom(String)     // custom font family name (e.g. "Manrope")
    case rounded            // system rounded design
}
```

### VxHubEnvironment

```swift
public enum VxHubEnvironment: String {
    case stage    // staging backend
    case prod     // production backend
}
```

### VxHubAppLifecycle

```swift
public enum VxHubAppLifecycle: String {
    case appDelegate
    case sceneDelegate
}
```

### LogLevel

```swift
public enum LogLevel: Int, Comparable {
    case verbose = 0
    case debug   = 1
    case info    = 2
    case warning = 3
    case error   = 4
}
```

### VxConnection

```swift
public enum VxConnection: String {
    case unavailable    // "No Connection"
    case wifi           // "WiFi"
    case cellular       // "Cellular"
}
```

### PromoOfferType

```swift
public enum PromoOfferType {
    case v1
}
```
