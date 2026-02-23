#if canImport(UIKit)
import UIKit

struct VxStoreDataSourceModel: Hashable {
    let id: Int
    let identifier: String
    let title: String
    let description: String
    let localizedPrice: String
    let price: Decimal
    let productType: VxStoreProductType
    let initialBonus: Int?
    let renewalBonus: Int?
    let isAlreadyPurchased: Bool
    var isSelected: Bool

    // Display
    let font: VxFont
    let isLightMode: Bool
    let textColor: UIColor
    var badgeText: String?
    var badgeColor: UIColor?
    var badgeTextColor: UIColor?
    var productImageName: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isSelected)
        hasher.combine(isAlreadyPurchased)
    }

    static func == (lhs: VxStoreDataSourceModel, rhs: VxStoreDataSourceModel) -> Bool {
        return lhs.id == rhs.id && lhs.isSelected == rhs.isSelected && lhs.isAlreadyPurchased == rhs.isAlreadyPurchased
    }
}

enum VxStoreDataSourceSection: Hashable {
    case main
}
#endif
