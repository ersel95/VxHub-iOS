import UIKit

public struct VxMainPaywallConfiguration {
    let topImage: UIImage
    let title: String
    let titleFont: UIFont
    let descriptionItems: [(image: String, text: String)]
    let descriptionItemFont: UIFont
    let freeTrialStackBorderColor: UIColor
    let subscriptionProductsBorderColor: UIColor
    let mainButtonColor: UIColor
    let mainButtonFont: UIFont
    let backgroundColor: UIColor
    
    public init(
        topImage: UIImage,
        title: String,
        titleFont: UIFont = .systemFont(ofSize: 24, weight: .bold),
        descriptionItems: [(image: String, text: String)],
        descriptionItemFont: UIFont = .systemFont(ofSize: 16, weight: .regular),
        freeTrialStackBorderColor: UIColor = .red,
        subscriptionProductsBorderColor: UIColor = .green,
        mainButtonColor: UIColor = .purple,
        mainButtonFont: UIFont = .systemFont(ofSize: 16, weight: .semibold),
        backgroundColor: UIColor = .white
    ) {
        self.topImage = topImage
        self.title = title
        self.titleFont = titleFont
        self.descriptionItems = descriptionItems
        self.descriptionItemFont = descriptionItemFont
        self.freeTrialStackBorderColor = freeTrialStackBorderColor
        self.subscriptionProductsBorderColor = subscriptionProductsBorderColor
        self.mainButtonColor = mainButtonColor
        self.mainButtonFont = mainButtonFont
        self.backgroundColor = backgroundColor
    }
} 