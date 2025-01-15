import UIKit

public enum VxMainPaywallLayoutConfiguration: Int, @unchecked Sendable {
    case dynamicTitle
    case dynamicDescription
}

public struct VxMainPaywallConfiguration: @unchecked Sendable {
    let font: VxPaywallFont
    let topImage: UIImage
    let titleImage: UIImage?
    let titleImageHeight: CGFloat
    let descriptionFont: VxPaywallFont
    let descriptionItems: [(image: String, text: String)]
    let freeTrialStackBorderColor: UIColor
    let mainButtonColor: UIColor
    let backgroundColor: UIColor
    let backgroundImage: UIImage?
    let isLightMode: Bool
    let textColor: UIColor
    
    public init(
        font: VxPaywallFont = .rounded,
        topImage: UIImage,
        titleText: String?,
        titleImage: UIImage?,
        titleImageHeight: CGFloat,
        descriptionFont: VxPaywallFont,
        descriptionItems: [(image: String, text: String)],
        freeTrialStackBorderColor: UIColor = .red,
        mainButtonColor: UIColor = .purple,
        backgroundColor: UIColor = .white,
        backgroundImage: UIImage? = nil,
        isLightMode: Bool = true,
        textColor: UIColor? = nil,
        layoutConfiguration: VxMainPaywallLayoutConfiguration
    ) {
        self.font = font
        self.topImage = topImage
        self.titleImage = titleImage
        self.titleImageHeight = titleImageHeight
        self.descriptionFont = descriptionFont
        self.descriptionItems = descriptionItems
        self.freeTrialStackBorderColor = freeTrialStackBorderColor
        self.mainButtonColor = mainButtonColor
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.isLightMode = isLightMode
        self.textColor = textColor ?? (isLightMode ? .black : .white)
    }
} 
