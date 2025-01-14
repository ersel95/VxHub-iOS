import UIKit

public enum VxFontWeight: CaseIterable {
    case regular
    case medium
    case semibold
    case bold
    
    var systemWeight: UIFont.Weight {
        switch self {
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        }
    }
    
    var suffixForCustomFont: String {
        switch self {
        case .regular: return "-Regular"
        case .medium: return "-Medium"
        case .semibold: return "-SemiBold"
        case .bold: return "-Bold"
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
