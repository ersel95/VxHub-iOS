#if canImport(UIKit)
import UIKit

final class VxStoreUtil {
    var storeProducts: [VxStoreDataSourceModel] = []
    private(set) var isDummyMode: Bool = false

    init(
        hideAlreadyPurchased: Bool,
        font: VxFont,
        isLightMode: Bool,
        textColor: UIColor,
        badges: [VxStoreProductBadge],
        images: [VxStoreProductImage],
        defaultImage: String?,
        dummyProducts: [VxStoreDummyProduct] = []
    ) {
        let allProducts = VxHub.shared.revenueCatProducts.filter {
            $0.storeProduct.productType == .consumable || $0.storeProduct.productType == .nonConsumable
        }

        if !allProducts.isEmpty {
            buildFromRealProducts(
                allProducts: allProducts,
                hideAlreadyPurchased: hideAlreadyPurchased,
                font: font, isLightMode: isLightMode, textColor: textColor,
                badges: badges, images: images, defaultImage: defaultImage
            )
        } else {
            #if DEBUG
            if !dummyProducts.isEmpty {
                isDummyMode = true
                VxLogger.shared.warning("[VxStore] No real products found — using dummy products (DEBUG)")
                buildFromDummyProducts(
                    dummyProducts: dummyProducts,
                    hideAlreadyPurchased: hideAlreadyPurchased,
                    font: font, isLightMode: isLightMode, textColor: textColor,
                    badges: badges, images: images, defaultImage: defaultImage
                )
            }
            #endif
        }
    }

    private func buildFromRealProducts(
        allProducts: [VxStoreProduct],
        hideAlreadyPurchased: Bool,
        font: VxFont, isLightMode: Bool, textColor: UIColor,
        badges: [VxStoreProductBadge], images: [VxStoreProductImage], defaultImage: String?
    ) {
        let keychain = VxKeychainManager()

        for (index, product) in allProducts.enumerated() {
            let identifier = product.storeProduct.productIdentifier
            let isNonConsumable = product.storeProduct.productType == .nonConsumable
            let isAlreadyPurchased = isNonConsumable && keychain.isNonConsumableActive(identifier)

            if hideAlreadyPurchased && isAlreadyPurchased {
                continue
            }

            let badge = badges.first(where: { $0.productIdentifier == identifier })
            let image = images.first(where: { $0.productIdentifier == identifier })

            let model = VxStoreDataSourceModel(
                id: index,
                identifier: identifier,
                title: product.storeProduct.localizedTitle,
                description: product.storeProduct.localizedDescription,
                localizedPrice: product.storeProduct.localizedPriceString,
                price: product.storeProduct.price,
                productType: product.storeProduct.productType,
                initialBonus: product.initialBonus,
                renewalBonus: product.renewalBonus,
                isAlreadyPurchased: isAlreadyPurchased,
                isSelected: false,
                font: font,
                isLightMode: isLightMode,
                textColor: textColor,
                badgeText: badge?.badgeText,
                badgeColor: badge?.badgeColor,
                badgeTextColor: badge?.badgeTextColor,
                productImageName: image?.imageName ?? defaultImage
            )

            storeProducts.append(model)
        }
    }

    private func buildFromDummyProducts(
        dummyProducts: [VxStoreDummyProduct],
        hideAlreadyPurchased: Bool,
        font: VxFont, isLightMode: Bool, textColor: UIColor,
        badges: [VxStoreProductBadge], images: [VxStoreProductImage], defaultImage: String?
    ) {
        let keychain = VxKeychainManager()

        for (index, dummy) in dummyProducts.enumerated() {
            let isNonConsumable = dummy.productType == .nonConsumable
            let isAlreadyPurchased = isNonConsumable && keychain.isNonConsumableActive(dummy.identifier)

            if hideAlreadyPurchased && isAlreadyPurchased {
                continue
            }

            let badge = badges.first(where: { $0.productIdentifier == dummy.identifier })
            let image = images.first(where: { $0.productIdentifier == dummy.identifier })

            let model = VxStoreDataSourceModel(
                id: index,
                identifier: dummy.identifier,
                title: dummy.title,
                description: dummy.description,
                localizedPrice: dummy.localizedPrice,
                price: dummy.price,
                productType: dummy.productType,
                initialBonus: dummy.initialBonus,
                renewalBonus: dummy.renewalBonus,
                isAlreadyPurchased: isAlreadyPurchased,
                isSelected: false,
                font: font,
                isLightMode: isLightMode,
                textColor: textColor,
                badgeText: badge?.badgeText,
                badgeColor: badge?.badgeColor,
                badgeTextColor: badge?.badgeTextColor,
                productImageName: image?.imageName ?? defaultImage
            )

            storeProducts.append(model)
        }
    }
}
#endif
