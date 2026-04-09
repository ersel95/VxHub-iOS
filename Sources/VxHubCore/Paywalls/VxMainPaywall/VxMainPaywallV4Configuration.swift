#if canImport(UIKit)
import UIKit

// MARK: - VxMainPaywallV4Configuration
// ============================================================================
// V4 Paywall Configuration — Apple Guideline 3.1.2(c) Compliant Variant
// ============================================================================
//
// PURPOSE:
//   Drop-in replacement for VxMainPaywallV3Configuration. The configuration
//   API is intentionally identical to V3 so that consumers only need to change
//   `showPaywallV3` → `showPaywallV4` — no parameter changes required.
//
// INTEGRATION (for consuming apps):
//   1. Import VxHubCore (or VxHub umbrella)
//   2. Create a VxMainPaywallV4Configuration instance (same params as V3)
//   3. Call VxHub.shared.showPaywallV4(from:configuration:...) instead of showPaywallV3
//
// EXAMPLE:
//   let config = VxMainPaywallV4Configuration(
//       font: .rounded,
//       heroImageName: "premium_hero",
//       backgroundColor: .white,
//       isLightMode: true,
//       headlineText: "Go Premium",
//       subtitleText: "Unlock all features",
//       featureItems: [
//           (icon: "checkmark.circle.fill", text: "Unlimited access"),
//           (icon: "star.fill", text: "No ads")
//       ],
//       ratingValue: "4.8",
//       ratingCount: "12.5K",
//       ctaButtonColor: .systemBlue,
//       ctaGradientEndColor: .systemPurple,
//       trustText: "Cancel anytime",
//       isCloseButtonEnabled: true,
//       closeButtonDelay: 3.0,
//       analyticsEvents: [.select, .purchased]
//   )
//
//   VxHub.shared.showPaywallV4(
//       from: viewController,
//       configuration: config,
//       completion: { success, productId in ... },
//       onRestoreStateChange: { restored in ... },
//       onReedemCodeButtonTapped: { ... }
//   )
//
// WHAT CHANGED VS V3:
//   - Configuration struct: NOTHING — identical API surface
//   - Product cell (VxV4PaywallProductCell): Billed price is now the largest/boldest
//     element; free trial text is subordinate (12pt regular, muted gray)
//   - CTA button: Always includes billed price in text
//   - See VxV4PaywallProductCell.swift and VxMainSubscriptionV4RootView.swift
//     for the actual compliance changes
// ============================================================================

public struct VxMainPaywallV4Configuration: @unchecked Sendable {
    // Branding
    let font: VxFont
    let heroImageName: String?
    let backgroundColor: UIColor
    let isLightMode: Bool
    let textColor: UIColor

    // Content
    let headlineText: String?
    let subtitleText: String?
    let featureItems: [(icon: String, text: String)]

    // Rating / Social Proof
    let ratingValue: String?
    let ratingCount: String?

    // CTA
    let ctaButtonColor: UIColor
    let ctaGradientEndColor: UIColor?

    // Trust line
    let trustText: String?

    // Controls
    let isCloseButtonEnabled: Bool
    let closeButtonColor: UIColor
    let analyticsEvents: [AnalyticEvents]?

    // Close button delay (seconds) — 0 = always visible
    let closeButtonDelay: TimeInterval

    public init(
        font: VxFont = .rounded,
        heroImageName: String? = nil,
        backgroundColor: UIColor = .white,
        isLightMode: Bool = true,
        textColor: UIColor? = nil,
        headlineText: String? = nil,
        subtitleText: String? = nil,
        featureItems: [(icon: String, text: String)] = [],
        ratingValue: String? = nil,
        ratingCount: String? = nil,
        ctaButtonColor: UIColor = .systemBlue,
        ctaGradientEndColor: UIColor? = nil,
        trustText: String? = nil,
        isCloseButtonEnabled: Bool = true,
        closeButtonColor: UIColor = .gray,
        analyticsEvents: [AnalyticEvents]? = nil,
        closeButtonDelay: TimeInterval = 0
    ) {
        self.font = font
        self.heroImageName = heroImageName
        self.backgroundColor = backgroundColor
        self.isLightMode = isLightMode
        self.textColor = textColor ?? (isLightMode ? .black : .white)
        self.headlineText = headlineText
        self.subtitleText = subtitleText
        self.featureItems = featureItems
        self.ratingValue = ratingValue
        self.ratingCount = ratingCount
        self.ctaButtonColor = ctaButtonColor
        self.ctaGradientEndColor = ctaGradientEndColor
        self.trustText = trustText
        self.isCloseButtonEnabled = isCloseButtonEnabled
        self.closeButtonColor = closeButtonColor
        self.analyticsEvents = analyticsEvents
        self.closeButtonDelay = closeButtonDelay
    }
}
#endif
