import UIKit

public struct VxMainPaywallConfiguration: @unchecked Sendable {
    let font: VxPaywallFont
    let appLogoImageName: String
    let appNameImageName: String?
    let descriptionFont: VxPaywallFont
    let descriptionItems: [(image: String, text: String)]
    let mainButtonColor: UIColor
    let backgroundColor: UIColor
    let backgroundImageName: String?
    let isLightMode: Bool
    let textColor: UIColor
    
    public init(
        font: VxPaywallFont = .rounded,
        appLogoImageName: String,
        appNameImageName: String?,
        descriptionFont: VxPaywallFont,
        descriptionItems: [(image: String, text: String)],
        mainButtonColor: UIColor = .purple,
        backgroundColor: UIColor = .white,
        backgroundImageName: String? = nil,
        isLightMode: Bool = true,
        textColor: UIColor? = nil
    ) {
        self.font = font
        self.appLogoImageName = appLogoImageName
        self.appNameImageName = appNameImageName
        self.descriptionFont = descriptionFont
        self.descriptionItems = descriptionItems
        self.mainButtonColor = mainButtonColor
        self.backgroundColor = backgroundColor
        self.backgroundImageName = backgroundImageName
        self.isLightMode = isLightMode
        self.textColor = textColor ?? (isLightMode ? .black : .white)
    }
} 
