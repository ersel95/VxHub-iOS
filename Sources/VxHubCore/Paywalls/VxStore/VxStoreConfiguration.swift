#if canImport(UIKit)
import UIKit

// MARK: - Enums

public enum VxStoreType: Int, Sendable {
    case v1, v2
}

public enum VxStorePurchaseMode: Int, Sendable {
    case perCard
    case selectAndBuy
}

// MARK: - Dummy Product (for testing without backend)

public struct VxStoreDummyProduct: @unchecked Sendable {
    public let identifier: String
    public let title: String
    public let description: String
    public let localizedPrice: String
    public let price: Decimal
    public let productType: VxStoreProductType
    public let initialBonus: Int?
    public let renewalBonus: Int?

    public init(
        identifier: String,
        title: String,
        description: String = "",
        localizedPrice: String,
        price: Decimal,
        productType: VxStoreProductType = .consumable,
        initialBonus: Int? = nil,
        renewalBonus: Int? = nil
    ) {
        self.identifier = identifier
        self.title = title
        self.description = description
        self.localizedPrice = localizedPrice
        self.price = price
        self.productType = productType
        self.initialBonus = initialBonus
        self.renewalBonus = renewalBonus
    }
}

// MARK: - Badge & Image

public struct VxStoreProductBadge: @unchecked Sendable {
    public let productIdentifier: String
    public let badgeText: String
    public let badgeColor: UIColor
    public let badgeTextColor: UIColor

    public init(
        productIdentifier: String,
        badgeText: String,
        badgeColor: UIColor = .systemBlue,
        badgeTextColor: UIColor = .white
    ) {
        self.productIdentifier = productIdentifier
        self.badgeText = badgeText
        self.badgeColor = badgeColor
        self.badgeTextColor = badgeTextColor
    }
}

public struct VxStoreProductImage: @unchecked Sendable {
    public let productIdentifier: String
    public let imageName: String

    public init(productIdentifier: String, imageName: String) {
        self.productIdentifier = productIdentifier
        self.imageName = imageName
    }
}

// MARK: - V1 Configuration (Grid)

public struct VxStoreV1Configuration: @unchecked Sendable {
    // Branding
    public let font: VxFont
    public let backgroundColor: UIColor
    public let isLightMode: Bool
    public let textColor: UIColor

    // Header
    public let heroImageName: String?
    public let headlineText: String?
    public let subtitleText: String?

    // Balance Display
    public let showBalance: Bool
    public let balanceIcon: String?
    public let balanceLabel: String?

    // Grid Layout
    public let columnsCount: Int
    public let cardCornerRadius: CGFloat
    public let cardBackgroundColor: UIColor
    public let cardBorderColor: UIColor
    public let cardBorderWidth: CGFloat
    public let selectedCardBorderColor: UIColor
    public let selectedCardBorderWidth: CGFloat

    // Product Card
    public let productImageSize: CGFloat
    public let productImages: [VxStoreProductImage]
    public let defaultProductImage: String?
    public let showBonusLabel: Bool
    public let bonusLabelColor: UIColor

    // Per-card buy button (perCard mode)
    public let buyButtonColor: UIColor
    public let buyButtonGradientEndColor: UIColor?
    public let buyButtonTextColor: UIColor
    public let buyButtonCornerRadius: CGFloat

    // Badges
    public let productBadges: [VxStoreProductBadge]

    // Purchase Mode
    public let purchaseMode: VxStorePurchaseMode

    // CTA Button (selectAndBuy mode only)
    public let ctaButtonColor: UIColor
    public let ctaGradientEndColor: UIColor?
    public let ctaButtonTextColor: UIColor
    public let ctaText: String?

    // Controls
    public let isCloseButtonEnabled: Bool
    public let closeButtonColor: UIColor
    public let closeButtonDelay: TimeInterval
    public let analyticsEvents: [AnalyticEvents]?

    // Non-consumable
    public let hideAlreadyPurchasedNonConsumables: Bool
    public let purchasedBadgeText: String?
    public let purchasedBadgeColor: UIColor

    // Dummy products (fallback for DEBUG when no backend products)
    public let dummyProducts: [VxStoreDummyProduct]

    public init(
        font: VxFont = .rounded,
        backgroundColor: UIColor = .white,
        isLightMode: Bool = true,
        textColor: UIColor? = nil,
        heroImageName: String? = nil,
        headlineText: String? = nil,
        subtitleText: String? = nil,
        showBalance: Bool = true,
        balanceIcon: String? = "dollarsign.circle.fill",
        balanceLabel: String? = "Your Balance:",
        columnsCount: Int = 2,
        cardCornerRadius: CGFloat = 16,
        cardBackgroundColor: UIColor = .secondarySystemBackground,
        cardBorderColor: UIColor = .separator,
        cardBorderWidth: CGFloat = 1,
        selectedCardBorderColor: UIColor = .systemBlue,
        selectedCardBorderWidth: CGFloat = 2.5,
        productImageSize: CGFloat = 48,
        productImages: [VxStoreProductImage] = [],
        defaultProductImage: String? = "bag.fill",
        showBonusLabel: Bool = true,
        bonusLabelColor: UIColor = .systemGreen,
        buyButtonColor: UIColor = .systemBlue,
        buyButtonGradientEndColor: UIColor? = nil,
        buyButtonTextColor: UIColor = .white,
        buyButtonCornerRadius: CGFloat = 10,
        productBadges: [VxStoreProductBadge] = [],
        purchaseMode: VxStorePurchaseMode = .perCard,
        ctaButtonColor: UIColor = .systemBlue,
        ctaGradientEndColor: UIColor? = nil,
        ctaButtonTextColor: UIColor = .white,
        ctaText: String? = "Purchase",
        isCloseButtonEnabled: Bool = true,
        closeButtonColor: UIColor = .gray,
        closeButtonDelay: TimeInterval = 0,
        analyticsEvents: [AnalyticEvents]? = nil,
        hideAlreadyPurchasedNonConsumables: Bool = true,
        purchasedBadgeText: String? = "OWNED",
        purchasedBadgeColor: UIColor = .systemGreen,
        dummyProducts: [VxStoreDummyProduct] = []
    ) {
        self.font = font
        self.backgroundColor = backgroundColor
        self.isLightMode = isLightMode
        self.textColor = textColor ?? (isLightMode ? .black : .white)
        self.heroImageName = heroImageName
        self.headlineText = headlineText
        self.subtitleText = subtitleText
        self.showBalance = showBalance
        self.balanceIcon = balanceIcon
        self.balanceLabel = balanceLabel
        self.columnsCount = columnsCount
        self.cardCornerRadius = cardCornerRadius
        self.cardBackgroundColor = cardBackgroundColor
        self.cardBorderColor = cardBorderColor
        self.cardBorderWidth = cardBorderWidth
        self.selectedCardBorderColor = selectedCardBorderColor
        self.selectedCardBorderWidth = selectedCardBorderWidth
        self.productImageSize = productImageSize
        self.productImages = productImages
        self.defaultProductImage = defaultProductImage
        self.showBonusLabel = showBonusLabel
        self.bonusLabelColor = bonusLabelColor
        self.buyButtonColor = buyButtonColor
        self.buyButtonGradientEndColor = buyButtonGradientEndColor
        self.buyButtonTextColor = buyButtonTextColor
        self.buyButtonCornerRadius = buyButtonCornerRadius
        self.productBadges = productBadges
        self.purchaseMode = purchaseMode
        self.ctaButtonColor = ctaButtonColor
        self.ctaGradientEndColor = ctaGradientEndColor
        self.ctaButtonTextColor = ctaButtonTextColor
        self.ctaText = ctaText
        self.isCloseButtonEnabled = isCloseButtonEnabled
        self.closeButtonColor = closeButtonColor
        self.closeButtonDelay = closeButtonDelay
        self.analyticsEvents = analyticsEvents
        self.hideAlreadyPurchasedNonConsumables = hideAlreadyPurchasedNonConsumables
        self.purchasedBadgeText = purchasedBadgeText
        self.purchasedBadgeColor = purchasedBadgeColor
        self.dummyProducts = dummyProducts
    }
}

// MARK: - V2 Configuration (List)

public struct VxStoreV2Configuration: @unchecked Sendable {
    // Branding
    public let font: VxFont
    public let backgroundColor: UIColor
    public let isLightMode: Bool
    public let textColor: UIColor

    // Header
    public let heroImageName: String?
    public let headlineText: String?
    public let subtitleText: String?

    // Balance Display
    public let showBalance: Bool
    public let balanceIcon: String?
    public let balanceLabel: String?

    // Card
    public let cardCornerRadius: CGFloat
    public let cardBackgroundColor: UIColor
    public let cardBorderColor: UIColor
    public let cardBorderWidth: CGFloat
    public let selectedCardBorderColor: UIColor
    public let selectedCardBorderWidth: CGFloat

    // Product
    public let productImageSize: CGFloat
    public let productImages: [VxStoreProductImage]
    public let defaultProductImage: String?
    public let showBonusLabel: Bool
    public let bonusLabelColor: UIColor
    public let showProductDescription: Bool
    public let productFeatures: [String: [(icon: String, text: String)]]

    // Social Proof
    public let socialProofText: String?
    public let socialProofIcon: String?

    // Buy Button
    public let buyButtonColor: UIColor
    public let buyButtonGradientEndColor: UIColor?
    public let buyButtonTextColor: UIColor
    public let buyButtonCornerRadius: CGFloat

    // Badges
    public let productBadges: [VxStoreProductBadge]

    // Purchase Mode
    public let purchaseMode: VxStorePurchaseMode

    // CTA Button (selectAndBuy mode only)
    public let ctaButtonColor: UIColor
    public let ctaGradientEndColor: UIColor?
    public let ctaButtonTextColor: UIColor
    public let ctaText: String?

    // Controls
    public let isCloseButtonEnabled: Bool
    public let closeButtonColor: UIColor
    public let closeButtonDelay: TimeInterval
    public let analyticsEvents: [AnalyticEvents]?

    // Non-consumable
    public let hideAlreadyPurchasedNonConsumables: Bool
    public let purchasedBadgeText: String?
    public let purchasedBadgeColor: UIColor

    // Dummy products (fallback for DEBUG when no backend products)
    public let dummyProducts: [VxStoreDummyProduct]

    public init(
        font: VxFont = .rounded,
        backgroundColor: UIColor = .white,
        isLightMode: Bool = true,
        textColor: UIColor? = nil,
        heroImageName: String? = nil,
        headlineText: String? = nil,
        subtitleText: String? = nil,
        showBalance: Bool = true,
        balanceIcon: String? = "dollarsign.circle.fill",
        balanceLabel: String? = "Your Balance:",
        cardCornerRadius: CGFloat = 16,
        cardBackgroundColor: UIColor = .secondarySystemBackground,
        cardBorderColor: UIColor = .separator,
        cardBorderWidth: CGFloat = 1,
        selectedCardBorderColor: UIColor = .systemBlue,
        selectedCardBorderWidth: CGFloat = 2.5,
        productImageSize: CGFloat = 48,
        productImages: [VxStoreProductImage] = [],
        defaultProductImage: String? = "bag.fill",
        showBonusLabel: Bool = true,
        bonusLabelColor: UIColor = .systemGreen,
        showProductDescription: Bool = true,
        productFeatures: [String: [(icon: String, text: String)]] = [:],
        socialProofText: String? = nil,
        socialProofIcon: String? = "star.fill",
        buyButtonColor: UIColor = .systemBlue,
        buyButtonGradientEndColor: UIColor? = nil,
        buyButtonTextColor: UIColor = .white,
        buyButtonCornerRadius: CGFloat = 10,
        productBadges: [VxStoreProductBadge] = [],
        purchaseMode: VxStorePurchaseMode = .perCard,
        ctaButtonColor: UIColor = .systemBlue,
        ctaGradientEndColor: UIColor? = nil,
        ctaButtonTextColor: UIColor = .white,
        ctaText: String? = "Purchase",
        isCloseButtonEnabled: Bool = true,
        closeButtonColor: UIColor = .gray,
        closeButtonDelay: TimeInterval = 0,
        analyticsEvents: [AnalyticEvents]? = nil,
        hideAlreadyPurchasedNonConsumables: Bool = true,
        purchasedBadgeText: String? = "OWNED",
        purchasedBadgeColor: UIColor = .systemGreen,
        dummyProducts: [VxStoreDummyProduct] = []
    ) {
        self.font = font
        self.backgroundColor = backgroundColor
        self.isLightMode = isLightMode
        self.textColor = textColor ?? (isLightMode ? .black : .white)
        self.heroImageName = heroImageName
        self.headlineText = headlineText
        self.subtitleText = subtitleText
        self.showBalance = showBalance
        self.balanceIcon = balanceIcon
        self.balanceLabel = balanceLabel
        self.cardCornerRadius = cardCornerRadius
        self.cardBackgroundColor = cardBackgroundColor
        self.cardBorderColor = cardBorderColor
        self.cardBorderWidth = cardBorderWidth
        self.selectedCardBorderColor = selectedCardBorderColor
        self.selectedCardBorderWidth = selectedCardBorderWidth
        self.productImageSize = productImageSize
        self.productImages = productImages
        self.defaultProductImage = defaultProductImage
        self.showBonusLabel = showBonusLabel
        self.bonusLabelColor = bonusLabelColor
        self.showProductDescription = showProductDescription
        self.productFeatures = productFeatures
        self.socialProofText = socialProofText
        self.socialProofIcon = socialProofIcon
        self.buyButtonColor = buyButtonColor
        self.buyButtonGradientEndColor = buyButtonGradientEndColor
        self.buyButtonTextColor = buyButtonTextColor
        self.buyButtonCornerRadius = buyButtonCornerRadius
        self.productBadges = productBadges
        self.purchaseMode = purchaseMode
        self.ctaButtonColor = ctaButtonColor
        self.ctaGradientEndColor = ctaGradientEndColor
        self.ctaButtonTextColor = ctaButtonTextColor
        self.ctaText = ctaText
        self.isCloseButtonEnabled = isCloseButtonEnabled
        self.closeButtonColor = closeButtonColor
        self.closeButtonDelay = closeButtonDelay
        self.analyticsEvents = analyticsEvents
        self.hideAlreadyPurchasedNonConsumables = hideAlreadyPurchasedNonConsumables
        self.purchasedBadgeText = purchasedBadgeText
        self.purchasedBadgeColor = purchasedBadgeColor
        self.dummyProducts = dummyProducts
    }
}
#endif
