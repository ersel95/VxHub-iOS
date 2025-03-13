import UIKit

extension UIFont {
    static func custom(_ font: VxFont, size: CGFloat, weight: VxFontWeight = .regular) -> UIFont {
        return VxFontManager.shared.font(font: font, size: size, weight: weight)
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

