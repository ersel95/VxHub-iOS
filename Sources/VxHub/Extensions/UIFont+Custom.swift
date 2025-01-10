import UIKit

extension UIFont {
    static func custom(_ fontFamily: String, size: CGFloat, weight: VxFontWeight = .regular) -> UIFont {
        if VxFontManager.shared.customFontFamily == nil {
            VxFontManager.shared.setCustomFontFamily(fontFamily)
            VxFontManager.shared.registerCustomFonts()
        }
        
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

