#if canImport(UIKit)
//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import Foundation
import UIKit

public final class VxPaywallDescriptionItem: UIStackView {
    
    private let imageSystemName: String
    private let descriptionText: String
    private let iconFrameSize: CGFloat
    private let iconBoundsSize: CGFloat
        
    private lazy var imageVerticalStack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.backgroundColor = .clear
        stack.spacing = 0
        return stack
    }()
    
    private lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var imageVerticalStackSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var imageVerticalStackTopPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var imageVerticalStackBottomPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: imageSystemName)
        return imageView
    }()
    
    private lazy var descriptionVerticalStack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.backgroundColor = .clear
        stack.spacing = 0
        return stack
    }()
    
    private lazy var descriptionLabel: VxLabel = {
        let label = VxLabel()
        label.textColor = .black
        label.numberOfLines = 0
//        label.localize(descriptionText)
        return label
    }()
    
    private lazy var descriptionLabelTopPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var descriptionLabelBottomPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var descriptionVerticalStackBottomSpacer = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var horizontalSpacerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    public init(
        frame: CGRect = .zero,
        imageSystemName: String = "checkmark.circle.fill",
        description: String,
        font: VxFont,
        textColor: UIColor = .black,
        fontSize: CGFloat = 16,
        iconFrameSize: CGFloat = 24,
        iconBoundsSize: CGFloat = 18,
        fontWeight: VxFontWeight = .bold
    ) {
        self.imageSystemName = imageSystemName
        self.descriptionText = description
        self.iconFrameSize = iconFrameSize
        self.iconBoundsSize = iconBoundsSize
        super.init(frame: frame)
        setupUI()
        constructHierarchy()
        descriptionLabel.textColor = textColor
        descriptionLabel.text = description
        descriptionLabel.setFont(font, size: fontSize, weight: fontWeight)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        axis = .horizontal
        spacing = 8
        distribution = .fill
        alignment = .fill
        
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        imageVerticalStack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func constructHierarchy() {
        addArrangedSubview(imageVerticalStack)
        imageVerticalStack.addArrangedSubview(imageVerticalStackTopPadding)
        imageVerticalStack.addArrangedSubview(imageContainerView)
        imageVerticalStack.addArrangedSubview(imageVerticalStackBottomPadding)
        imageVerticalStack.addArrangedSubview(imageVerticalStackSpacer)
        imageContainerView.addSubview(checkmarkImageView)

        
        addArrangedSubview(descriptionVerticalStack)
        descriptionVerticalStack.addArrangedSubview(descriptionLabelTopPadding)
        descriptionVerticalStack.addArrangedSubview(descriptionLabel)
        descriptionVerticalStack.addArrangedSubview(descriptionLabelBottomPadding)
        descriptionVerticalStack.addArrangedSubview(descriptionVerticalStackBottomSpacer)
        
        addArrangedSubview(horizontalSpacerView)
        
        NSLayoutConstraint.activate([
            imageVerticalStack.widthAnchor.constraint(equalToConstant: iconFrameSize),
            imageContainerView.heightAnchor.constraint(equalToConstant: iconFrameSize),
            checkmarkImageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            checkmarkImageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: iconBoundsSize),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: iconBoundsSize),
            imageVerticalStackTopPadding.heightAnchor.constraint(equalToConstant: 6),
            imageVerticalStackBottomPadding.heightAnchor.constraint(equalToConstant: 6),
            descriptionLabelBottomPadding.heightAnchor.constraint(equalToConstant: 6),
            descriptionLabelTopPadding.heightAnchor.constraint(equalToConstant: 6),
            descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: iconFrameSize)
        ])
        self.descriptionLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
}
#endif
