import UIKit

extension UIFont {
    static func custom(_ font: VxPaywallFont, size: CGFloat, weight: VxFontWeight = .regular) -> UIFont {
        VxFontManager.shared.setFont(font)
        return VxFontManager.shared.font(size: size, weight: weight)
    }
}

extension UIFont.Weight {
    var vxWeight: VxFontWeight {
        switch self {
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        default: return .regular
        }
    }
}

