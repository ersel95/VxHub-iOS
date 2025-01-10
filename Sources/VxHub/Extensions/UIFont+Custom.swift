import UIKit

extension UIFont {
    static func custom(_ fontName: String, size: CGFloat, weight: Weight = .regular) -> UIFont {
         let customFont = UIFont(name: fontName, size: size)!
        debugPrint("Font implemented",fontName)
//        {
//            return customFont
//        }
        
//        let systemFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
//            .addingAttributes([UIFontDescriptor.AttributeName.traits: [UIFontDescriptor.TraitKey.weight: weight]])
//            .withDesign(.rounded) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        return customFont
    }
}

