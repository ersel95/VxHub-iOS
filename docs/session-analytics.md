# VxHub Session Analytics - iOS Integration Guide

## Overview

VxHub Session Analytics tracks user journeys through your app to identify drop-off points and optimize conversion flows. The system is completely generic - you define what to track based on your app's unique flow. All tracked data appears in the VxHub panel where you can analyze screen flows, drop-off points, and build custom conversion funnels.

## Setup

### 1. Session Management (Automatic)

VxHub automatically manages sessions. A new session starts when the app comes to foreground and ends when it goes to background. No setup needed - this is handled internally by the SDK.

Sessions automatically capture:
- Session start/end timestamps
- Session duration
- Exit screen (the last screen viewed before the app went to background)
- Total events per session

### 2. Screen Tracking

Track every significant screen in your app. This is the foundation of journey analysis.

**UIKit:**

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    VxHub.shared.trackScreen("OnboardingStep1")
}
```

**SwiftUI:**

```swift
.onAppear {
    VxHub.shared.trackScreen("OnboardingStep1")
}
```

**Important:** Call `trackScreen` every time a screen appears, not just on first load. The SDK handles deduplication and timing internally.

### 3. Event Tracking

Track user actions and state changes with optional properties for segmentation.

```swift
// User tapped a button
VxHub.shared.trackEvent("button_tap", properties: ["button": "skip_onboarding"])

// Paywall was shown
VxHub.shared.trackEvent("paywall_shown", properties: ["variant": "v2", "source": "onboarding"])

// User started a feature
VxHub.shared.trackEvent("feature_used", properties: ["feature": "photo_filter", "filter_name": "vintage"])

// Purchase flow
VxHub.shared.trackEvent("purchase_started", properties: ["product_id": "premium_monthly"])
VxHub.shared.trackEvent("purchase_completed", properties: ["product_id": "premium_monthly", "price": 9.99])
VxHub.shared.trackEvent("purchase_cancelled", properties: ["product_id": "premium_monthly"])
```

Properties are arbitrary key-value pairs. Use them to add context that helps you segment and filter data in the panel.

## Recommended Events

These are suggestions - track what makes sense for YOUR app. The panel lets you build funnels from any combination of events, so collect broadly and analyze later.

### Onboarding Flow

```swift
// Track each onboarding screen
VxHub.shared.trackScreen("Onboarding1")
VxHub.shared.trackScreen("Onboarding2")
VxHub.shared.trackScreen("Onboarding3")
VxHub.shared.trackScreen("OnboardingComplete")

// Track onboarding actions
VxHub.shared.trackEvent("onboarding_next", properties: ["from_step": 1])
VxHub.shared.trackEvent("onboarding_skip", properties: ["at_step": 2])
VxHub.shared.trackEvent("onboarding_complete")
```

### Paywall & Purchases

```swift
// Paywall display
VxHub.shared.trackScreen("Paywall")
VxHub.shared.trackEvent("paywall_shown", properties: [
    "variant": "annual_first",
    "source": "onboarding",        // or "settings", "feature_gate", etc.
    "products_shown": "monthly,annual"
])

// Paywall interactions
VxHub.shared.trackEvent("paywall_dismissed")
VxHub.shared.trackEvent("purchase_started", properties: ["product_id": "premium_monthly", "price": 9.99])
VxHub.shared.trackEvent("purchase_completed", properties: ["product_id": "premium_monthly", "price": 9.99])
VxHub.shared.trackEvent("purchase_failed", properties: ["product_id": "premium_monthly", "error": "cancelled"])
VxHub.shared.trackEvent("restore_purchases_tapped")
VxHub.shared.trackEvent("restore_purchases_success")
```

### Core Features

```swift
// Track feature screens
VxHub.shared.trackScreen("PhotoEditor")
VxHub.shared.trackScreen("FilterSelection")
VxHub.shared.trackScreen("ExportScreen")

// Track feature usage
VxHub.shared.trackEvent("feature_used", properties: [
    "feature": "photo_filter",
    "action": "apply",
    "filter_name": "vintage"
])
VxHub.shared.trackEvent("feature_used", properties: [
    "feature": "photo_filter",
    "action": "remove"
])
```

### Settings & Account

```swift
VxHub.shared.trackScreen("Settings")
VxHub.shared.trackScreen("Account")

VxHub.shared.trackEvent("settings_changed", properties: ["setting": "notifications", "value": "off"])
VxHub.shared.trackEvent("subscription_cancelled", properties: ["product_id": "premium_monthly"])
VxHub.shared.trackEvent("account_deleted")
```

### Notifications & Deep Links

```swift
VxHub.shared.trackEvent("push_received", properties: ["campaign_id": "spring_sale"])
VxHub.shared.trackEvent("push_opened", properties: ["campaign_id": "spring_sale"])
VxHub.shared.trackEvent("deeplink_opened", properties: ["url": "myapp://feature/editor"])
```

## API Reference

### VxHub.shared.trackScreen(_ name: String)

Records a screen view. Automatically captures:
- Timestamp
- Current session ID
- Previous screen name (for flow analysis)
- Time spent on previous screen (duration from last `trackScreen` call)

**Parameters:**
- `name` - A consistent string identifier for the screen. Use PascalCase or camelCase (e.g., `"OnboardingStep1"`, `"PhotoEditor"`, `"Settings"`).

**Behavior:**
- Calling `trackScreen` with a new name automatically ends the timing for the previous screen.
- The first `trackScreen` call in a session marks the entry screen.
- The last screen tracked before session end is recorded as the exit screen.

### VxHub.shared.trackEvent(_ name: String, properties: [String: Any]? = nil)

Records a custom event with optional properties.

**Parameters:**
- `name` - The event name. Use snake_case (e.g., `"purchase_completed"`, `"button_tap"`).
- `properties` - Optional dictionary of key-value pairs. Values can be `String`, `Int`, `Double`, `Bool`. Nested objects are not supported.

**Behavior:**
- Events are associated with the current session and current screen automatically.
- Events are batched and sent efficiently - no need to worry about network overhead.
- If called when no session is active (rare edge case), the event is queued and attached to the next session.

## Best Practices

1. **Use consistent screen names across your app.** `"Paywall"` and `"PaywallScreen"` will be treated as two different screens. Pick a convention and stick with it.

2. **Track every screen transition, not just important ones.** The flow analysis works best when it has complete data. Missing screens create gaps in the user journey.

3. **Add properties that help segment data.** Properties like `variant`, `source`, `product_id`, and `feature` let you filter and compare in the panel.

4. **Don't over-track.** Focus on the conversion flow you want to optimize. Every screen view and key user action should be tracked, but you don't need to track every UI interaction.

5. **Use snake_case for event names.** This keeps things consistent and readable in the analytics panel: `purchase_completed`, `paywall_shown`, `feature_used`.

6. **Build funnels from tracked data.** The panel lets you create custom funnels from any combination of events and screen views. Collect broadly so you have flexibility to analyze different flows later.

7. **Track both positive and negative outcomes.** Track `purchase_completed` AND `purchase_cancelled`. Track `onboarding_complete` AND `onboarding_skip`. This gives you drop-off data.

8. **Use the `source` property liberally.** Knowing WHERE a paywall was triggered from (onboarding vs settings vs feature gate) is often more valuable than just knowing it was shown.

## Complete Example: Photo Filter App

Here is a comprehensive integration for a photo filter app with onboarding, paywall, and core editing features.

```swift
import VxHub

// MARK: - App Delegate / Scene Delegate
// No setup needed for session analytics - VxHub handles session lifecycle automatically.

// MARK: - Onboarding Flow

class OnboardingViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VxHub.shared.trackScreen("Onboarding")
        VxHub.shared.trackEvent("onboarding_step", properties: ["step": 1])
    }

    @IBAction func nextTapped() {
        VxHub.shared.trackEvent("onboarding_next", properties: ["from_step": 1])
        // Navigate to next step
    }

    @IBAction func skipTapped() {
        VxHub.shared.trackEvent("onboarding_skip", properties: ["at_step": 1])
        // Skip to home
    }
}

// MARK: - Paywall

class PaywallViewController: UIViewController {
    var source: String = "onboarding" // or "settings", "feature_gate"
    var variant: String = "annual_first"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VxHub.shared.trackScreen("Paywall")
        VxHub.shared.trackEvent("paywall_shown", properties: [
            "variant": variant,
            "source": source
        ])
    }

    @IBAction func purchaseTapped(_ product: Product) {
        VxHub.shared.trackEvent("purchase_started", properties: [
            "product_id": product.id,
            "price": product.price
        ])

        // After purchase completes:
        VxHub.shared.trackEvent("purchase_completed", properties: [
            "product_id": product.id,
            "price": product.price
        ])
    }

    @IBAction func dismissTapped() {
        VxHub.shared.trackEvent("paywall_dismissed", properties: ["source": source])
        dismiss(animated: true)
    }
}

// MARK: - Home Screen

class HomeViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VxHub.shared.trackScreen("Home")
    }

    @IBAction func openEditor() {
        VxHub.shared.trackEvent("feature_selected", properties: ["feature": "photo_filter"])
        // Navigate to editor
    }
}

// MARK: - Photo Editor

class PhotoEditorViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VxHub.shared.trackScreen("PhotoEditor")
    }

    func applyFilter(_ filterName: String) {
        VxHub.shared.trackEvent("filter_applied", properties: ["filter": filterName])
    }

    @IBAction func exportTapped() {
        VxHub.shared.trackEvent("export_started")
        // Navigate to result
    }
}

// MARK: - Result Screen

class ResultViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VxHub.shared.trackScreen("Result")
    }

    @IBAction func saveTapped() {
        VxHub.shared.trackEvent("result_saved")
    }

    @IBAction func shareTapped(_ platform: String) {
        VxHub.shared.trackEvent("result_shared", properties: ["platform": platform])
    }
}
```

### SwiftUI Equivalent

```swift
import SwiftUI
import VxHub

struct OnboardingView: View {
    @State private var currentStep = 1

    var body: some View {
        VStack {
            // Onboarding content
            Button("Next") {
                VxHub.shared.trackEvent("onboarding_next", properties: ["from_step": currentStep])
                currentStep += 1
            }
        }
        .onAppear {
            VxHub.shared.trackScreen("Onboarding")
            VxHub.shared.trackEvent("onboarding_step", properties: ["step": currentStep])
        }
    }
}

struct PaywallView: View {
    let source: String
    let variant: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            // Paywall content
            Button("Subscribe") {
                VxHub.shared.trackEvent("purchase_started", properties: [
                    "product_id": "premium_monthly",
                    "source": source
                ])
            }
            Button("Not Now") {
                VxHub.shared.trackEvent("paywall_dismissed", properties: ["source": source])
                dismiss()
            }
        }
        .onAppear {
            VxHub.shared.trackScreen("Paywall")
            VxHub.shared.trackEvent("paywall_shown", properties: [
                "variant": variant,
                "source": source
            ])
        }
    }
}

struct HomeView: View {
    var body: some View {
        VStack {
            // Home content
        }
        .onAppear {
            VxHub.shared.trackScreen("Home")
        }
    }
}

struct PhotoEditorView: View {
    var body: some View {
        VStack {
            // Editor content
        }
        .onAppear {
            VxHub.shared.trackScreen("PhotoEditor")
        }
    }

    func applyFilter(_ name: String) {
        VxHub.shared.trackEvent("filter_applied", properties: ["filter": name])
    }
}

struct ResultView: View {
    var body: some View {
        VStack {
            Button("Save") {
                VxHub.shared.trackEvent("result_saved")
            }
            Button("Share") {
                VxHub.shared.trackEvent("result_shared", properties: ["platform": "instagram"])
            }
        }
        .onAppear {
            VxHub.shared.trackScreen("Result")
        }
    }
}
```

## Using the VxHub Panel

After integrating tracking, you can use the VxHub panel to:

### 1. Overview Dashboard (`/user-journey`)
See total sessions, average duration, bounce rate, top screens, and top exit screens at a glance.

### 2. Screen Analytics (`/user-journey/screens`)
View detailed per-screen metrics: views, unique users, average time spent, entry rate, and exit rate. Click any screen name to see its drop-off analysis.

### 3. Screen Flow (`/user-journey/flow`)
See the most common screen-to-screen transitions. This shows you the actual paths users take through your app.

### 4. Drop-off Analysis (`/user-journey/dropoff`)
Select a specific screen to see: how many users viewed it, how many exited the app from that screen, and where the rest navigated to next.

### 5. Custom Funnels (`/user-journey/funnels`)
Build custom conversion funnels from any combination of events. For example:

**Onboarding to Purchase Funnel:**
1. `screen_view` where `screen_name` = `"Onboarding"`
2. `screen_view` where `screen_name` = `"Paywall"`
3. `purchase_completed`
4. `screen_view` where `screen_name` = `"PhotoEditor"`
5. `result_saved`

The funnel visualization shows exactly where users drop off between each step, with conversion percentages and absolute counts.

## Troubleshooting

**Events not appearing in the panel:**
- Ensure VxHub is initialized before calling tracking methods.
- Check that the app has network connectivity - events are batched and sent periodically.
- Allow a few minutes for data to appear in the panel.

**Screen durations seem wrong:**
- Make sure you call `trackScreen` in `viewDidAppear` (UIKit) or `.onAppear` (SwiftUI), not in `viewDidLoad` or `init`.
- Ensure every screen calls `trackScreen` - gaps in tracking will produce incorrect duration calculations.

**Session counts are too high:**
- Each foreground/background cycle creates a new session. This is expected behavior.
- If your app frequently backgrounds (e.g., during camera/photo picker use), consider if this affects your analysis.
