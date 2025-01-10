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
        imageView.image = UIImage(systemName: imageSystemName)
        return imageView
    }()
    
    private lazy var descriptionVerticalStack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.backgroundColor = .clear
        stack.spacing = 0
        return stack
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.text = descriptionText
        label.numberOfLines = 0
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
        font: UIFont = .systemFont(ofSize: 16, weight: .regular)
    ) {
        self.imageSystemName = imageSystemName
        self.descriptionText = description
        super.init(frame: frame)
        setupUI()
        constructHierarchy()
        descriptionLabel.font = font
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        axis = .horizontal
        spacing = 10
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
            imageVerticalStack.widthAnchor.constraint(equalToConstant: 24),
            imageContainerView.heightAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            checkmarkImageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 18),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 18),
            imageVerticalStackTopPadding.heightAnchor.constraint(equalToConstant: 10),
            imageVerticalStackBottomPadding.heightAnchor.constraint(equalToConstant: 10),
            descriptionLabelBottomPadding.heightAnchor.constraint(equalToConstant: 10),
            descriptionLabelTopPadding.heightAnchor.constraint(equalToConstant: 10),
            descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 24) // in order to center in one line
        ])
        self.descriptionLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    public func configure(with text: String) {
        descriptionLabel.text = text
    }
}
