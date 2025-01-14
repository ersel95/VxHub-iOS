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
    
    private var fontType: VxPaywallFont = .system("SF Pro")
    private var registeredFonts: Set<String> = []
    
    private init() {}
    
    public func setFont(_ font: VxPaywallFont) {
        self.fontType = font
        if case .custom = font {
            registerCustomFonts()
        }
    }
    
    public func font(size: CGFloat, weight: VxFontWeight = .regular) -> UIFont {
        switch fontType {
        case .system(let familyName):
            return UIFont(name: familyName, size: size) ?? .systemFont(ofSize: size, weight: weight.systemWeight)
            
        case .rounded:
            let systemFont = UIFont.systemFont(ofSize: size, weight: weight.systemWeight)
            if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: descriptor, size: size)
            }
            return systemFont
            
        case .custom(let familyName):
            let fontName = familyName + weight.suffixForCustomFont
            if let customFont = UIFont(name: fontName, size: size) {
                return customFont
            }
            
            if let baseFont = UIFont(name: familyName, size: size) {
                return baseFont
            }
            
            return .systemFont(ofSize: size, weight: weight.systemWeight)
        }
    }
    
    private func registerCustomFonts() {
        guard case .custom(let familyName) = fontType else { return }
        
        VxFontWeight.allCases.forEach { weight in
            let fontName = familyName + weight.suffixForCustomFont
            if !registeredFonts.contains(fontName) {
                if let fontURL = Bundle.module.url(forResource: fontName, withExtension: "ttf") {
                    CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
                    registeredFonts.insert(fontName)
                }
            }
        }
    }
} 
