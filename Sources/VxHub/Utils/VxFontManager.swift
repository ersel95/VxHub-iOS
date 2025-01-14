import UIKit

public enum VxPaywallFont: @unchecked Sendable {
    case system(String)
    case custom(String)
    case rounded
}

public enum VxFontWeight: CaseIterable {
    case thin
    case ultraLight
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy
    case black
    
    var systemWeight: UIFont.Weight {
        switch self {
        case .thin: return .thin
        case .ultraLight: return .ultraLight
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        }
    }
    
    var suffixForCustomFont: String {
        switch self {
        case .thin: return "-Thin"
        case .ultraLight: return "-ExtraLight"
        case .light: return "-Light"
        case .regular: return "-Regular"
        case .medium: return "-Medium"
        case .semibold: return "-SemiBold"
        case .bold: return "-Bold"
        case .heavy: return "-ExtraBold"
        case .black: return "-Black"
        }
    }
}

public class VxFontManager: @unchecked Sendable {
    public static let shared = VxFontManager()
        
    private init() {}
    
    public func font(font: VxPaywallFont, size: CGFloat, weight: VxFontWeight = .regular) -> UIFont {
        switch font {
        case .system(let familyName):
            if let font = UIFont(name: familyName, size: size) {
                return font
            }
            #if DEBUG
            assertionFailure("System font '\(familyName)' not found. Falling back to system font.")
            #endif
            return .systemFont(ofSize: size, weight: weight.systemWeight)
            
        case .rounded:
            if let descriptor = UIFont.systemFont(ofSize: size, weight: weight.systemWeight).fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: descriptor, size: size)
            }
            #if DEBUG
            assertionFailure("Rounded system font not available. Falling back to regular system font.")
            #endif
            return .systemFont(ofSize: size, weight: weight.systemWeight)
            
        case .custom(let familyName):
            let fontName = familyName + weight.suffixForCustomFont
            if let customFont = UIFont(name: fontName, size: size) {
                return customFont
            }
            
            #if DEBUG
            assertionFailure("Custom font '\(fontName)' not found. Trying base family name.")
            #endif
            
            if let baseFont = UIFont(name: familyName, size: size) {
                return baseFont
            }
            
            #if DEBUG
            assertionFailure("Base font '\(familyName)' not found either. Falling back to system font.")
            #endif
            
            return .systemFont(ofSize: size, weight: weight.systemWeight)
        }
    }
} 
