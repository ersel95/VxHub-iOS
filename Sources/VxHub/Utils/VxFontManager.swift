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
    
    public var customFontFamily: String?
    private var registeredFonts: Set<String> = []
    
    private init() {}
    
    public func setCustomFontFamily(_ fontFamily: String) {
        self.customFontFamily = fontFamily
    }
    
    public func font(size: CGFloat, weight: VxFontWeight = .regular) -> UIFont {
        if let customFontFamily = customFontFamily {
            let fontName = customFontFamily + weight.suffixForCustomFont
            if let customFont = UIFont(name: fontName, size: size) {
                return customFont
            }
            
            // Fallback to base font if specific weight not found
            if let baseFont = UIFont(name: customFontFamily, size: size) {
                return baseFont
            }
        }
        
        // Fallback to system font
        return .systemFont(ofSize: size, weight: weight.systemWeight)
    }
    
    public func registerCustomFonts() {
        guard let customFontFamily = customFontFamily else { return }
        
        // Register fonts if bundle contains them
        VxFontWeight.allCases.forEach { weight in
            let fontName = customFontFamily + weight.suffixForCustomFont
            if !registeredFonts.contains(fontName) {
                if let fontURL = Bundle.module.url(forResource: fontName, withExtension: "ttf") {
                    CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
                    registeredFonts.insert(fontName)
                }
            }
        }
    }
} 
