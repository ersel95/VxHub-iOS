import UIKit

extension UIFont {
    static func custom(_ fontName: String, size: CGFloat, weight: Weight = .regular) -> UIFont {
        if let customFont = UIFont(name: fontName, size: size) {
            return customFont
        }
        return .systemFont(ofSize: size, weight: weight)
    }
} 
