# VxHub iOS SDK — Troubleshooting

Common integration issues and solutions.

## "VxHub failed with error"

**Cause:** Invalid `hubId` or wrong environment.

**Fix:**
- Verify your `hubId` is correct (UUID format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)
- Check environment matches your backend: `.prod` for production, `.stage` for staging
- Confirm your device has internet connectivity

```swift
let config = VxHubConfig(hubId: "your-correct-hub-id", environment: .prod)
```

## Empty products / revenueCatProducts is []

**Cause:** Products not configured on backend, or init not complete.

**Fix:**
- Ensure RevenueCat products are configured in the VxHub backend dashboard
- Only access `revenueCatProducts` after `vxHubDidInitialize()` fires
- Check that product identifiers match between App Store Connect and backend
- On simulator, products may not load — test on a real device

## Google Sign-In not working

**Cause:** Missing URL scheme in Info.plist.

**Fix:**
1. The Google client key comes from backend automatically — you don't hardcode it
2. But you still need the URL scheme in Info.plist for the OAuth redirect:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

3. Get the `REVERSED_CLIENT_ID` from the GoogleService-Info.plist that the SDK downloads (check app sandbox or logs)

## Paywall shows empty / no products

**Cause:** Calling `showMainPaywall` before SDK initialization completes.

**Fix:**
- Wait for `vxHubDidInitialize()` delegate callback before showing paywall
- Check `VxHub.shared.revenueCatProducts.count > 0` before presenting

```swift
func vxHubDidInitialize() {
    // Safe to show paywall here
    if !VxHub.shared.revenueCatProducts.isEmpty {
        // Show paywall
    }
}
```

## Warm start issues / stale data

**Cause:** Missing `start()` call in `applicationDidBecomeActive`.

**Fix:** Always call `start()` when app returns to foreground:

```swift
func applicationDidBecomeActive(_ application: UIApplication) {
    VxHub.shared.start()
}
```

Without this, the device won't re-register and data may become stale.

## Support view doesn't appear

**Cause:** `showContactUs` requires a `UINavigationController`.

**Fix:** The presenting view controller must be embedded in a navigation stack:

```swift
// Correct — VC has a navigation controller
VxHub.shared.showContactUs(from: self) // self is inside UINavigationController

// For SwiftUI, wrap in UINavigationController manually (see integration guide)
```

## Swift 6 concurrency warnings

**Cause:** VxHub uses `@unchecked Sendable` for some types. Swift 6 strict concurrency may flag warnings.

**Fix:**
- These are expected — VxHub manages thread safety internally
- The SDK's completion handlers are marked `@Sendable`
- Consider using the async/await API for cleaner concurrency:

```swift
let result = try await VxHub.shared.initialize(config: config, launchOptions: nil, application: app)
```

## mTLS / Certificate errors

**Cause:** Network requests failing with certificate pinning errors.

**Fix:**
- The SDK bundles mTLS certificates internally — no action needed from developer
- If you see certificate errors, ensure you're using the latest SDK version
- Check that your device clock is accurate (expired certs cause failures)
- Verify the environment (`.prod` vs `.stage`) matches your backend

## ATT dialog not showing

**Cause:** Missing `NSUserTrackingUsageDescription` in Info.plist, or `requestAtt` not enabled.

**Fix:**
1. Add to Info.plist:
```xml
<key>NSUserTrackingUsageDescription</key>
<string>We use this to provide personalized ads</string>
```

2. Either set `requestAtt: true` in config, or call manually:
```swift
let config = VxHubConfig(hubId: "...", requestAtt: true)
// or
VxHub.shared.requestAttPerm()
```

3. ATT dialog only shows once per app install — reset in Settings > General > Transfer or Reset

## App crashes on launch

**Cause:** Missing required initialization.

**Fix checklist:**
- Ensure `initialize()` is called in `didFinishLaunchingWithOptions`
- Do NOT call SDK methods before `vxHubDidInitialize()` fires
- Make sure you pass `application` parameter to `initialize()` (required for Facebook SDK setup)
- Check Xcode console for VxHub log messages (set `logLevel: .verbose` for debugging)
