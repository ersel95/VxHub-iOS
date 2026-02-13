#if canImport(UIKit)
//
//  ShowcaseItemView.swift
//  spamsms
//
//  Created by furkan on 20.01.2025.
//

import UIKit

final class ShowcaseItemView: UIView {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var titleLabel: VxLabel = {
        let label = VxLabel()
        label.textColor = .white
        label.setFont(.custom("Roboto"), size: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var gradientBackgroundView: GradientView = {
        let view = GradientView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(gradientBackgroundView)
        addSubview(stackView)
        
        // Change order: put image first, then title
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            gradientBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            gradientBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 48),
            iconImageView.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
    
    func configure(with category: SpecialOfferCategories) {
        titleLabel.text = category.title
        iconImageView.image = category.image
        gradientBackgroundView.setGradient(colors: category.gradientColors)
    }
}
#endif
