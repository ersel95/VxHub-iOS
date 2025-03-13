//
//  VxNotificationBanner.swift
//  VxHub
//
//  Created by Furkan Alioglu on 26.02.2025.
//

import UIKit
import NotificationBannerSwift

final class VxNotificationBannerView: VxNiblessView {
    
    //MARK: - Properties
    private var buttonAction: (@Sendable() -> Void)?
    var bannerModel: VxBannerModel
    
    private lazy var mainVerticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.layer.cornerRadius = 8
        return stack
    }()
    
    private lazy var mainHorizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 0
        return stack
    }()
    
    private lazy var iconVerticalStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var descriptionVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    lazy var descriptionTitleLabel: VxLabel = {
        let label = VxLabel()
        label.setFont(.custom("Manrope"), size: 12, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    private lazy var descriptionSubtitleLabel: VxLabel = {
        let label = VxLabel()
        label.setFont(.custom("Manrope"), size: 12, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    private lazy var buttonVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    private lazy var buttonContentVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 0
        stack.backgroundColor = .clear
        stack.layer.cornerRadius = 4
        stack.clipsToBounds = true
        stack.layer.borderColor = UIColor.white.cgColor
        stack.layer.borderWidth = 1
        return stack
    }()
    
    private lazy var buttonContentHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 0
        return stack
    }()
    
    private lazy var buttonLabel: VxLabel = {
        let label = VxLabel()
        label.setFont(.custom("Manrope"), size: 12, weight: .semibold)
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    public init(model: VxBannerModel,
                buttonAction: (@Sendable () -> Void)? = nil) {
        self.bannerModel = model
        super.init(frame: .zero)
        self.backgroundColor = .clear
        setupHierarchy()
        setupLayout()
        setContentHuggingPriorities()
        configure(type: model.type, title: model.title, buttonLabel: model.buttonLabel, buttonAction: buttonAction)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(type: VxBannerTypes, title: String?, buttonLabel: String?, buttonAction: (@Sendable() -> Void)?) {
        mainVerticalStackView.backgroundColor = type.backgroundColor
        iconImageView.image = UIImage(systemName: type.iconName)
        iconImageView.tintColor = .white
        
        if let title = title {
            descriptionTitleLabel.text = title
            descriptionTitleLabel.textColor = .white
        }
        
        if let buttonLabel = buttonLabel {
            self.buttonLabel.text = buttonLabel
            buttonVerticalStack.isHidden = false
        } else {
            buttonVerticalStack.isHidden = true
        }
        
        self.buttonAction = buttonAction
        
        if buttonAction != nil {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
            buttonContentVerticalStack.addGestureRecognizer(tapGesture)
            buttonContentVerticalStack.isUserInteractionEnabled = true
        }
    }
    
    @objc private func buttonTapped() {
        VxBannerManager.shared.currentBanner?.dismiss()
        buttonAction?()
    }
    
    private func setContentHuggingPriorities() {
        descriptionTitleLabel.setContentHuggingPriority(.required, for: .vertical)
//        descriptionTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        descriptionTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func setupHierarchy() {
        self.addSubview(mainVerticalStackView)
        mainVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        buttonVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        buttonContentVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        mainVerticalStackView.addArrangedSubview(UIView.spacer(height: 12))
        mainVerticalStackView.addArrangedSubview(self.mainHorizontalStackView)
        mainHorizontalStackView.addArrangedSubview(UIView.spacer(width: 14))
        mainHorizontalStackView.addArrangedSubview(self.iconVerticalStack)
        
        iconVerticalStack.addArrangedSubview(self.iconImageView)
        iconVerticalStack.addArrangedSubview(UIView.flexibleSpacer())
        
        mainHorizontalStackView.addArrangedSubview(UIView.spacer(width: 4))
        
        mainHorizontalStackView.addArrangedSubview(self.descriptionVerticalStack)
        descriptionVerticalStack.addArrangedSubview(self.descriptionTitleLabel)
        descriptionVerticalStack.addArrangedSubview(UIView.flexibleSpacer())
        
        if bannerModel.buttonLabel != nil {
            mainHorizontalStackView.addArrangedSubview(UIView.spacer(width: 11))
        }

        mainHorizontalStackView.addArrangedSubview(UIView.flexibleSpacer())
        mainHorizontalStackView.addArrangedSubview(buttonVerticalStack)
        buttonVerticalStack.addArrangedSubview(buttonContentVerticalStack)
        buttonContentVerticalStack.addArrangedSubview(UIView.spacer(height: 4))
        buttonContentVerticalStack.addArrangedSubview(buttonContentHorizontalStack)
        buttonContentHorizontalStack.addArrangedSubview(UIView.spacer(width: 10))
        buttonContentHorizontalStack.addArrangedSubview(buttonLabel)
        buttonContentHorizontalStack.addArrangedSubview(UIView.spacer(width: 10))
        buttonContentVerticalStack.addArrangedSubview(UIView.spacer(height: 4))
        buttonVerticalStack.addArrangedSubview(UIView.flexibleSpacer())
        
        mainVerticalStackView.addArrangedSubview(UIView.spacer(height: 12))
        mainHorizontalStackView.addArrangedSubview(UIView.spacer(width: 12))
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            mainVerticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            mainVerticalStackView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            iconVerticalStack.widthAnchor.constraint(equalToConstant: 20),
            
            buttonVerticalStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 59),
            buttonContentVerticalStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 24)
        ])
    }
}
