import UIKit

public struct VxMainPaywallConfiguration {
    let baseFont: String
    let topImage: UIImage
    let title: String
    let descriptionItems: [(image: String, text: String)]
    let freeTrialStackBorderColor: UIColor
    let subscriptionProductsBorderColor: UIColor
    let mainButtonColor: UIColor
    let backgroundColor: UIColor
    let backgroundImage: UIImage?
    let isLightMode: Bool
    let textColor: UIColor
    
    public init(
        baseFont: String = ".SFUI-Regular",
        topImage: UIImage,
        title: String,
        descriptionItems: [(image: String, text: String)],
        freeTrialStackBorderColor: UIColor = .red,
        subscriptionProductsBorderColor: UIColor = .green,
        mainButtonColor: UIColor = .purple,
        backgroundColor: UIColor = .white,
        backgroundImage: UIImage? = nil,
        isLightMode: Bool = true,
        textColor: UIColor? = nil
    ) {
        self.baseFont = baseFont
        self.topImage = topImage
        self.title = title
        self.descriptionItems = descriptionItems
        self.freeTrialStackBorderColor = freeTrialStackBorderColor
        self.subscriptionProductsBorderColor = subscriptionProductsBorderColor
        self.mainButtonColor = mainButtonColor
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.isLightMode = isLightMode
        self.textColor = textColor ?? (isLightMode ? .black : .white)
    }
} 
