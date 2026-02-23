import SwiftUI
import VxHub

// MARK: - Dummy Products for Testing

private let storeDummyProducts: [VxStoreDummyProduct] = [
    VxStoreDummyProduct(
        identifier: "com.stilyco.coins.100",
        title: "100 Coins",
        description: "A small pack of coins",
        localizedPrice: "$0.99",
        price: 0.99,
        productType: .consumable,
        initialBonus: 10
    ),
    VxStoreDummyProduct(
        identifier: "com.stilyco.coins.500",
        title: "500 Coins",
        description: "A medium pack of coins",
        localizedPrice: "$2.99",
        price: 2.99,
        productType: .consumable,
        initialBonus: 20
    ),
    VxStoreDummyProduct(
        identifier: "com.stilyco.coins.1200",
        title: "1200 Coins",
        description: "A large pack of coins",
        localizedPrice: "$4.99",
        price: 4.99,
        productType: .consumable,
        initialBonus: 40
    ),
    VxStoreDummyProduct(
        identifier: "com.stilyco.coins.3000",
        title: "3000 Coins",
        description: "The mega pack of coins",
        localizedPrice: "$9.99",
        price: 9.99,
        productType: .consumable,
        initialBonus: 60
    ),
    VxStoreDummyProduct(
        identifier: "com.stilyco.prodesignpack",
        title: "Pro Design Pack",
        description: "Unlock all design templates",
        localizedPrice: "$4.99",
        price: 4.99,
        productType: .nonConsumable
    ),
    VxStoreDummyProduct(
        identifier: "com.stilyco.removeads",
        title: "Remove Ads",
        description: "Remove all advertisements",
        localizedPrice: "$2.99",
        price: 2.99,
        productType: .nonConsumable
    )
]

struct StoreV1Example: View {
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack {
                Image(systemName: "bag.fill")
                    .foregroundColor(.orange)
                Text("Store V1 (Grid) Test")
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            VxStoreView(
                v1Configuration: VxStoreV1Configuration(
                    font: .rounded,
                    backgroundColor: .white,
                    isLightMode: true,
                    heroImageName: nil,
                    headlineText: "Coin Shop",
                    subtitleText: "Get more coins to unlock features!",
                    showBalance: true,
                    balanceIcon: "dollarsign.circle.fill",
                    balanceLabel: "Your Balance:",
                    columnsCount: 2,
                    cardCornerRadius: 16,
                    cardBackgroundColor: UIColor(white: 0.96, alpha: 1.0),
                    cardBorderColor: UIColor(white: 0.88, alpha: 1.0),
                    cardBorderWidth: 1,
                    selectedCardBorderColor: .systemOrange,
                    selectedCardBorderWidth: 2.5,
                    productImageSize: 44,
                    productImages: [
                        VxStoreProductImage(productIdentifier: "com.stilyco.coins.100", imageName: "diamond.fill"),
                        VxStoreProductImage(productIdentifier: "com.stilyco.coins.500", imageName: "diamond.fill"),
                        VxStoreProductImage(productIdentifier: "com.stilyco.coins.1200", imageName: "diamond.fill"),
                        VxStoreProductImage(productIdentifier: "com.stilyco.coins.3000", imageName: "diamond.fill"),
                        VxStoreProductImage(productIdentifier: "com.stilyco.prodesignpack", imageName: "paintbrush.fill"),
                        VxStoreProductImage(productIdentifier: "com.stilyco.removeads", imageName: "eye.slash.fill")
                    ],
                    showBonusLabel: true,
                    bonusLabelColor: .systemGreen,
                    buyButtonColor: .systemOrange,
                    buyButtonTextColor: .white,
                    buyButtonCornerRadius: 10,
                    productBadges: [
                        VxStoreProductBadge(productIdentifier: "com.stilyco.coins.500", badgeText: "POPULAR", badgeColor: .systemBlue, badgeTextColor: .white),
                        VxStoreProductBadge(productIdentifier: "com.stilyco.coins.1200", badgeText: "BEST VALUE", badgeColor: .systemOrange, badgeTextColor: .white)
                    ],
                    purchaseMode: .perCard,
                    isCloseButtonEnabled: true,
                    closeButtonColor: .gray,
                    closeButtonDelay: 0,
                    analyticsEvents: [.select, .purchased],
                    hideAlreadyPurchasedNonConsumables: false,
                    purchasedBadgeText: "OWNED",
                    purchasedBadgeColor: .systemGreen,
                    dummyProducts: storeDummyProducts
                ),
                onPurchaseSuccess: { productId in
                    print("Store V1 purchased: \(productId ?? "nil")")
                    isPresented = false
                },
                onDismiss: {
                    isPresented = false
                }
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct StoreV2Example: View {
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack {
                Image(systemName: "list.bullet.rectangle.fill")
                    .foregroundColor(.indigo)
                Text("Store V2 (List) Test")
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            VxStoreView(
                v2Configuration: VxStoreV2Configuration(
                    font: .rounded,
                    backgroundColor: .white,
                    isLightMode: true,
                    heroImageName: nil,
                    headlineText: "Premium Packs",
                    subtitleText: "Unlock powerful features",
                    showBalance: true,
                    balanceIcon: "dollarsign.circle.fill",
                    balanceLabel: "Your Balance:",
                    cardCornerRadius: 14,
                    cardBackgroundColor: UIColor(white: 0.96, alpha: 1.0),
                    cardBorderColor: UIColor(white: 0.88, alpha: 1.0),
                    cardBorderWidth: 1,
                    selectedCardBorderColor: .systemIndigo,
                    selectedCardBorderWidth: 2.5,
                    productImageSize: 36,
                    productImages: [
                        VxStoreProductImage(productIdentifier: "com.stilyco.coins.100", imageName: "diamond.fill"),
                        VxStoreProductImage(productIdentifier: "com.stilyco.coins.500", imageName: "diamond.fill"),
                        VxStoreProductImage(productIdentifier: "com.stilyco.coins.1200", imageName: "diamond.fill"),
                        VxStoreProductImage(productIdentifier: "com.stilyco.coins.3000", imageName: "diamond.fill"),
                        VxStoreProductImage(productIdentifier: "com.stilyco.prodesignpack", imageName: "paintbrush.fill"),
                        VxStoreProductImage(productIdentifier: "com.stilyco.removeads", imageName: "eye.slash.fill")
                    ],
                    showBonusLabel: true,
                    bonusLabelColor: .systemGreen,
                    showProductDescription: true,
                    productFeatures: [
                        "com.stilyco.prodesignpack": [
                            (icon: "checkmark.circle.fill", text: "100+ Templates"),
                            (icon: "checkmark.circle.fill", text: "Custom Colors"),
                            (icon: "checkmark.circle.fill", text: "Export HD")
                        ],
                        "com.stilyco.removeads": [
                            (icon: "checkmark.circle.fill", text: "No banner ads"),
                            (icon: "checkmark.circle.fill", text: "No interstitials")
                        ]
                    ],
                    socialProofText: "500K+ users trust us",
                    socialProofIcon: "star.fill",
                    buyButtonColor: .systemIndigo,
                    buyButtonTextColor: .white,
                    buyButtonCornerRadius: 10,
                    productBadges: [
                        VxStoreProductBadge(productIdentifier: "com.stilyco.prodesignpack", badgeText: "POPULAR", badgeColor: .systemIndigo, badgeTextColor: .white),
                        VxStoreProductBadge(productIdentifier: "com.stilyco.coins.1200", badgeText: "BEST VALUE", badgeColor: .systemOrange, badgeTextColor: .white)
                    ],
                    purchaseMode: .selectAndBuy,
                    ctaButtonColor: .systemIndigo,
                    ctaGradientEndColor: UIColor(red: 120/255, green: 80/255, blue: 255/255, alpha: 1.0),
                    ctaButtonTextColor: .white,
                    ctaText: "Purchase Now",
                    isCloseButtonEnabled: true,
                    closeButtonColor: .gray,
                    closeButtonDelay: 0,
                    analyticsEvents: [.select, .purchased],
                    hideAlreadyPurchasedNonConsumables: false,
                    purchasedBadgeText: "OWNED",
                    purchasedBadgeColor: .systemGreen,
                    dummyProducts: storeDummyProducts
                ),
                onPurchaseSuccess: { productId in
                    print("Store V2 purchased: \(productId ?? "nil")")
                    isPresented = false
                },
                onDismiss: {
                    isPresented = false
                }
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}
