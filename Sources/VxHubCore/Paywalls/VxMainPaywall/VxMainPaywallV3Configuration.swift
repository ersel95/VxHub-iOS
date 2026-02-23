#if canImport(UIKit)
import UIKit

public struct VxMainPaywallV3Configuration: @unchecked Sendable {
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
