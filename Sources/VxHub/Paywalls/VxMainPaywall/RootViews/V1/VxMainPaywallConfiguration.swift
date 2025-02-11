import UIKit

public enum VxMainPaywallTypes: Int {
    case v1, v2
}

public struct VxMainPaywallConfiguration: @unchecked Sendable {
    let paywallType: Int
    let font: VxPaywallFont
    let appLogoImageName: String
    let appNameImageName: String?
    let descriptionFont: VxPaywallFont
    let descriptionItems: [(image: String, text: String)]
    let mainButtonColor: UIColor
    let backgroundColor: UIColor
    let backgroundImageName: String?
    let videoBundleName: String?
    let isLightMode: Bool
    let textColor: UIColor
    
    public init(
        paywallType: Int,
        font: VxPaywallFont = .rounded,
        appLogoImageName: String,
        appNameImageName: String?,
        descriptionFont: VxPaywallFont,
        descriptionItems: [(image: String, text: String)],
        mainButtonColor: UIColor = .purple,
        backgroundColor: UIColor = .white,
        backgroundImageName: String? = nil,
        videoBundleName: String? = nil,
        isLightMode: Bool = true,
        textColor: UIColor? = nil
    ) {
        self.paywallType = paywallType
        self.font = font
        self.appLogoImageName = appLogoImageName
        self.appNameImageName = appNameImageName
        self.descriptionFont = descriptionFont
        self.descriptionItems = descriptionItems
        self.mainButtonColor = mainButtonColor
        self.backgroundColor = backgroundColor
        self.backgroundImageName = backgroundImageName
        self.videoBundleName = videoBundleName
        self.isLightMode = isLightMode
        self.textColor = textColor ?? (isLightMode ? .black : .white)
    }
} 
