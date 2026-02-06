# VxHub iOS SDK — Integration Guide

Complete integration guide with copy-paste ready code examples for every feature.

## 1. Installation (SPM)

1. In Xcode: **File → Add Package Dependencies**
2. Enter URL: `https://github.com/ersel95/VxHub-iOS.git`
3. Select **Up to Next Major Version**
4. Add `VxHub` to your target

## 2. Info.plist Configuration

Add these entries to your app's `Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Tracking Transparency (required if requestAtt: true) -->
    <key>NSUserTrackingUsageDescription</key>
    <string>We use this identifier to show you personalized ads</string>

    <!-- Google Sign-In URL Scheme -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <!-- Replace with REVERSED_CLIENT_ID from your GoogleService-Info.plist -->
                <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
            </array>
        </dict>
    </array>

    <!-- App detection for installed app queries -->
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
</dict>
</plist>
```

> **Note:** `GoogleService-Info.plist` is downloaded automatically from the VxHub backend. Do NOT manually bundle it.

## 3. SwiftUI App (Recommended)

Use `@UIApplicationDelegateAdaptor` to bridge UIKit lifecycle:

```swift
import SwiftUI
import VxHub

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let config = VxHubConfig(
            hubId: "YOUR_HUB_ID",
            environment: .prod,
            logLevel: .verbose
        )
        VxHub.shared.initialize(
            config: config,
            delegate: self,
            launchOptions: launchOptions,
            application: application
        )
        return true
    }

    // IMPORTANT: Warm start — re-registers device on every foreground return
    func applicationDidBecomeActive(_ application: UIApplication) {
        VxHub.shared.start()
    }
}

extension AppDelegate: VxHubDelegate {
    func vxHubDidInitialize() {
        // SDK fully ready — products loaded, config available
        print("Premium: \(VxHub.shared.isPremium)")
        print("Products: \(VxHub.shared.revenueCatProducts.count)")
    }

    func vxHubDidStart() {
        // Called after warm start completes
    }

    func vxHubDidFailWithError(error: String?) {
        print("VxHub error: \(error ?? "unknown")")
    }

    // Optional delegates:
    func vxHubDidReceiveForceUpdate() {
        // Show force update UI
    }

    func vxHubDidReceiveBanned() {
        // Handle banned device
    }

    func vxHubDidChangeNetworkStatus(isConnected: Bool, connectionType: String) {
        // React to network changes
    }
}
```

## 4. UIKit AppDelegate

```swift
import UIKit
import VxHub

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let config = VxHubConfig(
            hubId: "YOUR_HUB_ID",
            environment: .prod,
            logLevel: .verbose
        )
        VxHub.shared.initialize(
            config: config,
            delegate: self,
            launchOptions: launchOptions,
            application: application
        )
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        VxHub.shared.start()
    }
}

extension AppDelegate: VxHubDelegate {
    func vxHubDidInitialize() { }
    func vxHubDidStart() { }
    func vxHubDidFailWithError(error: String?) { }
}
```

## 5. Async/Await Initialization

```swift
import VxHub

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Task {
            let config = VxHubConfig(hubId: "YOUR_HUB_ID", environment: .prod)
            do {
                let result = try await VxHub.shared.initialize(
                    config: config,
                    delegate: self,
                    launchOptions: launchOptions,
                    application: application
                )
                switch result {
                case .success:
                    print("SDK initialized — \(VxHub.shared.revenueCatProducts.count) products")
                case .banned:
                    print("Device is banned")
                case .forceUpdateRequired:
                    print("Force update required")
                }
            } catch {
                print("Init failed: \(error)")
            }
        }
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Task {
            let _ = try? await VxHub.shared.start()
        }
    }
}
```

## 6. Paywall

### UIKit — Show Paywall

```swift
let config = VxMainPaywallConfiguration(
    paywallType: VxMainPaywallTypes.v2.rawValue,
    font: .rounded,
    appLogoImageName: "app_logo",
    appNameImageName: "app_name",
    descriptionFont: .rounded,
    descriptionItems: [
        (image: "feature_icon_1", text: "Unlimited access"),
        (image: "feature_icon_2", text: "Ad-free experience"),
        (image: "feature_icon_3", text: "Premium features")
    ],
    mainButtonColor: .systemBlue,
    backgroundColor: .black,
    backgroundImageName: "paywall_bg",     // optional
    videoBundleName: "intro_video",        // optional, from bundle
    showGradientVideoBackground: true,
    isLightMode: false,
    textColor: .white,
    analyticsEvents: [.select, .purchased],
    isCloseButtonEnabled: true,
    closeButtonColor: .white
)

VxHub.shared.showMainPaywall(
    from: self,                            // UIViewController
    configuration: config,
    presentationStyle: VxPaywallPresentationStyle.present.rawValue,
    completion: { didPurchase, productIdentifier in
        if didPurchase {
            print("Purchased: \(productIdentifier ?? "")")
        }
    },
    onRestoreStateChange: { success in
        print("Restore: \(success)")
    },
    onReedemCodeButtonTapped: {
        // Show redeem code UI
    }
)
```

### SwiftUI — Paywall Wrapper

```swift
import SwiftUI
import VxHub

struct PaywallView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> VxMainSubscriptionViewController {
        let config = VxMainPaywallConfiguration(
            paywallType: VxMainPaywallTypes.v2.rawValue,
            appLogoImageName: "app_logo",
            appNameImageName: nil,
            descriptionFont: .rounded,
            descriptionItems: [
                (image: "icon1", text: "Feature 1"),
                (image: "icon2", text: "Feature 2")
            ],
            mainButtonColor: .systemBlue,
            backgroundColor: .black,
            isLightMode: false,
            isCloseButtonEnabled: true
        )

        let viewModel = VxMainSubscriptionViewModel(
            configuration: config,
            onPurchaseSuccess: { _ in },
            onDismissWithoutPurchase: { },
            onRestoreAction: { _ in },
            onReedemCodaButtonTapped: { }
        )

        let controller = VxMainSubscriptionViewController(viewModel: viewModel)
        controller.modalPresentationStyle = .overFullScreen
        return controller
    }

    func updateUIViewController(_ vc: VxMainSubscriptionViewController, context: Context) { }
}

// Usage in SwiftUI:
struct ContentView: View {
    @State private var showPaywall = false

    var body: some View {
        Button("Show Paywall") { showPaywall = true }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
                    .edgesIgnoringSafeArea(.all)
            }
    }
}
```

## 7. Purchases

### List Products

```swift
// Products are available after vxHubDidInitialize()
let products = VxHub.shared.revenueCatProducts

for product in products {
    print("\(product.storeProduct.localizedTitle) — \(product.storeProduct.localizedPriceString)")
    print("  Type: \(product.vxProductType ?? .consumable)")
    print("  Trial eligible: \(product.isDiscountOrTrialEligible)")
    print("  Initial bonus: \(product.initialBonus ?? 0)")
    print("  Renewal bonus: \(product.renewalBonus ?? 0)")
}
```

### Purchase a Product

```swift
// Callback
let product = VxHub.shared.revenueCatProducts.first!
VxHub.shared.purchase(product.storeProduct) { success in
    if success {
        print("Purchased! Premium: \(VxHub.shared.isPremium)")
    }
}

// Async
let success = await VxHub.shared.purchase(product.storeProduct)
```

### Restore Purchases

```swift
// Callback
VxHub.shared.restorePurchases { hasSubscription, hasNonConsumable, error in
    if let error { print("Error: \(error)") }
    print("Active sub: \(hasSubscription), Non-consumable: \(hasNonConsumable)")
}

// Async
let (hasSub, hasNonConsumable, error) = try await VxHub.shared.restorePurchases()
```

### Check Premium State

```swift
// Local (synced at init)
if VxHub.shared.isPremium { /* ... */ }

// Live from RevenueCat
VxHub.shared.getRevenueCatPremiumState { isPremium in
    print("Live premium: \(isPremium)")
}

// Async
let isPremium = await VxHub.shared.getRevenueCatPremiumState()
```

## 8. Authentication

### Google Sign-In

```swift
// Callback
VxHub.shared.signInWithGoogle(presenting: viewController) { success, error in
    if let error {
        print("Google sign-in error: \(error.localizedDescription)")
        return
    }
    if success == true {
        print("Signed in with Google")
    }
}

// Async
do {
    let success = try await VxHub.shared.signInWithGoogle(presenting: viewController)
    print("Google sign-in: \(success)")
} catch {
    print("Error: \(error)")
}
```

> **Note:** Google client ID is fetched from backend. You only need the URL scheme in Info.plist.

### Apple Sign-In

```swift
// Callback
VxHub.shared.signInWithApple(presenting: viewController) { success, error in
    if let error {
        print("Apple sign-in error: \(error.localizedDescription)")
        return
    }
    if success == true {
        print("Signed in with Apple")
    }
}

// Async
do {
    let success = try await VxHub.shared.signInWithApple(presenting: viewController)
    print("Apple sign-in: \(success)")
} catch {
    print("Error: \(error)")
}
```

### Logout

```swift
// Callback — logs out from RevenueCat, OneSignal, Amplitude, AppsFlyer
VxHub.shared.handleLogout { customerInfo, success in
    print("Logout success: \(success)")
}

// Async
let (info, success) = try await VxHub.shared.handleLogout()
```

### Delete Account

```swift
// Callback
VxHub.shared.deleteAccount { success, errorMessage in
    if success { print("Account deleted") }
}

// Async
let (success, error) = try await VxHub.shared.deleteAccount()
```

## 9. Customer Support

### UIKit — Show Support

```swift
// Default theme
VxHub.shared.showContactUs(from: navigationController!)

// Custom theme
let config = VxSupportConfiguration(
    font: .custom("Manrope"),
    backgroundColor: .black,
    navigationTintColor: .white,
    listingActionColor: .systemBlue,
    listingActionTextColor: .white,
    detailUserTicketBackgroundColor: .systemBlue,
    detailUserTicketMessageColor: .white
    // 30+ color parameters — all have sensible defaults
)
VxHub.shared.showContactUs(from: navigationController!, configuration: config)
```

> **Important:** `showContactUs` pushes onto a navigation stack. The presenting VC must be inside a `UINavigationController`.

### SwiftUI — Support Wrapper

```swift
import SwiftUI
import VxHub

struct SupportView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UINavigationController {
        let config = VxSupportConfiguration()
        let viewModel = VxSupportViewModel(
            appController: UIViewController(),
            configuration: config
        )
        let controller = VxSupportViewController(viewModel: viewModel)

        let dismissButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.dismiss)
        )
        dismissButton.tintColor = .label
        controller.navigationItem.leftBarButtonItem = dismissButton

        let nav = UINavigationController()
        nav.setViewControllers([controller], animated: false)
        return nav
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject {
        let parent: SupportView
        init(_ parent: SupportView) { self.parent = parent }
        @objc func dismiss() { parent.dismiss() }
    }

    func updateUIViewController(_ vc: UINavigationController, context: Context) { }
}

// Usage:
struct SettingsView: View {
    @State private var showSupport = false

    var body: some View {
        Button("Contact Us") { showSupport = true }
            .fullScreenCover(isPresented: $showSupport) {
                SupportView().edgesIgnoringSafeArea(.all)
            }
    }
}
```

### Check Unseen Tickets

```swift
// Callback
VxHub.shared.getTicketsUnseenStatus { hasUnseen, error in
    if hasUnseen { /* Show badge */ }
}

// Async
let (hasUnseen, _) = try await VxHub.shared.getTicketsUnseenStatus()
```

## 10. Promo Codes & QR Login

### Promo Code

```swift
// Callback
VxHub.shared.usePromoCode("PROMO123") { result in
    if let error = result.error {
        print("Invalid: \(error.message?.joined(separator: ", ") ?? "")")
        return
    }
    if let data = result.data {
        switch data.actionType {
        case .premium:
            print("Premium for \(data.actionMeta?.durationInDays ?? 0) days")
        case .coin:
            print("Got \(data.actionMeta?.coinAmount ?? 0) coins")
        case .discount:
            print("Discount package: \(data.actionMeta?.packageName ?? "")")
        case .none:
            break
        }
    }
}

// Async
let result = await VxHub.shared.usePromoCode("PROMO123")
```

### QR Code Login

```swift
// Callback
VxHub.shared.validateQrCode(token: scannedToken) { success, error in
    if success { print("QR login approved") }
}

// Async
let (success, error) = try await VxHub.shared.validateQrCode(token: scannedToken)
```

## 11. Media

### Images — Download & Retrieve

```swift
// Download
VxHub.shared.downloadImage(from: "https://example.com/image.png") { error in
    if error == nil { print("Downloaded") }
}

// Get cached UIImage
VxHub.shared.getDownloadedImage(from: "https://example.com/image.png") { (image: UIImage?) in
    imageView.image = image
}

// Get cached SwiftUI Image
VxHub.shared.getDownloadedImage(from: "https://example.com/image.png") { (image: Image?) in
    // Use in SwiftUI
}

// Batch download
VxHub.shared.downloadImages(from: ["url1", "url2", "url3"]) { downloadedUrls in
    print("Downloaded \(downloadedUrls.count) images")
}

// SDWebImage convenience (for UIImageView)
VxHub.shared.vxSetImage(
    on: imageView,
    with: URL(string: "https://example.com/img.png"),
    placeholderImage: UIImage(named: "placeholder"),
    showLoadingIndicator: true
)

// Compress
let compressed = VxHub.shared.compressImage(originalImage, maxDimension: 1024, quality: 0.8, maxSize: 1_048_576)
```

### Video

```swift
// Download
VxHub.shared.downloadVideo(from: "https://example.com/video.mp4") { error in
    if error == nil {
        let localPath = VxHub.shared.getDownloadedVideoPath(from: "https://example.com/video.mp4")
        // Play from localPath
    }
}
```

### Lottie Animations

```swift
// Download animation JSON
VxHub.shared.downloadLottieAnimation(from: "https://example.com/anim.json") { error in
    if error == nil { print("Animation downloaded") }
}

// Play in a view
VxHub.shared.createAndPlayAnimation(
    name: "confetti",                // animation file name
    in: containerView,               // parent UIView
    tag: 100,                        // unique tag for management
    removeOnFinish: true,
    loopAnimation: false,
    animationSpeed: 1.0,
    contentMode: .scaleAspectFit
) {
    print("Animation finished")
}

// Control
VxHub.shared.stopAnimation(with: 100)
VxHub.shared.removeAnimation(with: 100)
VxHub.shared.stopAllAnimations()
VxHub.shared.removeAllAnimations()
```

## 12. Analytics

### Amplitude

```swift
VxHub.shared.logAmplitudeEvent(
    eventName: "button_tapped",
    properties: ["screen": "home", "button": "premium"]
)
```

### AppsFlyer

```swift
VxHub.shared.logAppsFlyerEvent(
    eventName: "af_purchase",
    values: ["af_revenue": "9.99", "af_currency": "USD"]
)
```

### A/B Testing (Amplitude Experiments)

```swift
if let payload = VxHub.shared.getVariantPayload(for: "paywall_experiment") {
    let variant = payload["variant"] as? String
    print("User is in variant: \(variant ?? "control")")
}
```

## 13. Utility

### Legal Pages

```swift
VxHub.shared.showEula()                    // default
VxHub.shared.showEula(isFullScreen: true, showCloseButton: true)
VxHub.shared.showPrivacy()
VxHub.shared.presentWebUrl(url: URL(string: "https://example.com")!)
```

### App Review

```swift
VxHub.shared.requestReview()
// Smart: shows in-app review first, then redirects to App Store page on subsequent calls
```

### Language

```swift
// Check current
let lang = VxHub.shared.preferredLanguage        // e.g. "en"
let supported = VxHub.shared.supportedLanguages   // e.g. ["en", "tr", "de"]

// Change (re-downloads localizables)
VxHub.shared.changePreferredLanguage(to: "tr") { success in
    if success { print("Language changed") }
}

// Async
let success = try await VxHub.shared.changePreferredLanguage(to: "tr")
```

### Banners (In-App Notifications)

```swift
VxHub.shared.showBanner("Purchase successful!", type: .success, font: .rounded)
VxHub.shared.showBanner("No internet", type: .error, font: .rounded)
VxHub.shared.showBanner("New feature!", type: .info, font: .custom("Manrope"))

// With action button
VxHub.shared.showBanner(
    "Update available",
    type: .warning,
    font: .rounded,
    buttonLabel: "Update"
) {
    // Handle tap
}
```

### Retention Coins

```swift
// Claim daily gift
VxHub.shared.claimRetentionCoinGift { response, error in
    if let response {
        print("Gift amount: \(response.giftAmount ?? 0)")
        VxHub.shared.markRetentionCoinAsGiven()
    }
}

// Check if already claimed today
if !VxHub.shared.hasGivenRetentionCoin() {
    // Show claim UI
}

// Async
let response = try await VxHub.shared.claimRetentionCoinGift()
```

### ATT Permission

```swift
VxHub.shared.requestAttPerm()
```

### Network Monitoring

```swift
VxHub.shared.setupReachability()
print(VxHub.shared.isConnectedToInternet)

// Delegate callback
func vxHubDidChangeNetworkStatus(isConnected: Bool, connectionType: String) {
    print("\(connectionType): \(isConnected)")
}
```

### Promo Offers (Special Paywall)

```swift
VxHub.shared.showPromoOffer(
    from: self,
    productIdentifier: "com.app.weekly_promo",
    productToCompareIdentifier: "com.app.weekly",
    presentationStyle: VxPaywallPresentationStyle.present.rawValue,
    type: .v1
) { purchased in
    if purchased { print("Promo purchased") }
}
```

### Other Utilities

```swift
// Check if URL content is already downloaded
let cached = VxHub.shared.isDownloaded(url: someURL)

// Get IDFA
let idfa = VxHub.shared.getIDFA()

// Check simulator
let isSim = VxHub.shared.isSimulator()

// App Store ID (from backend)
let appId = VxHub.shared.appStoreId

// Device bottom safe area
VxHub.shared.configureDeviceInset()
let bottomInset = VxHub.shared.deviceBottomHeight

// Facebook deep link handling
VxHub.shared.openFbUrlIfNeeded(url: incomingURL)

// Sentry (manual init — usually auto-initialized by SDK)
VxHub.shared.startSentry(dsn: "https://...")
VxHub.shared.stopSentry()
```
