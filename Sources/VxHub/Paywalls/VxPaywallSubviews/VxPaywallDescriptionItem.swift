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
    
    private lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: imageSystemName)
        imageView.tintColor = .green
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.text = descriptionText
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var horizontalSpacerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    public init(frame: CGRect = .zero, imageSystemName: String = "checkmark.circle.fill", description: String) {
        self.imageSystemName = imageSystemName
        self.descriptionText = description
        super.init(frame: frame)
        setupUI()
        constructHierarchy()
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
    }
    
    private func constructHierarchy() {
        imageContainerView.addSubview(checkmarkImageView)
        
        addArrangedSubview(imageContainerView)
        addArrangedSubview(descriptionLabel)
        addArrangedSubview(horizontalSpacerView)
        
        NSLayoutConstraint.activate([
            imageContainerView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            checkmarkImageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 18),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 18)
        ])
        self.descriptionLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    public func configure(with text: String) {
        descriptionLabel.text = text
    }
}
