//
//  File.swift
//  VxHub
//
//  Created by furkan on 9.01.2025.
//

import UIKit

final class VxMainPaywallTableViewCell: VxNiblessTableViewCell {

    private lazy var mainContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    // MARK: - Base Views
    private lazy var mainVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layer.borderColor = UIColor.green.cgColor
        stackView.layer.borderWidth = 1
        stackView.spacing = 0
        return stackView
    }()

    private lazy var mainHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        return stackView
    }()
    // MARK: - End of Base Views

    // MARK: - Selected Dot View
    private lazy var selectedDotVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()

    private lazy var selectedDotHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()

    private lazy var selectedDotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = .red
        return imageView
    }()
    // MARK: - End of Selected Dot View

    // MARK: - Product Description View
    private lazy var productDescriptionVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var productDescriptionHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()    

    private lazy var productDescriptionTitle: UILabel = {
        let label = UILabel()
        label.text = "Yearly Accesss"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()

    private lazy var productDescriptionSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Unlimited Access to All Features"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()

    private lazy var productDescriptionSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    // MARK: - End of Product Description View

    // MARK: - Description to Price Spacer
    private lazy var descriptionToPriceSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    // MARK: - End of Description to Price Spacer

    // MARK: - Text Description View
    private lazy var priceDescriptionVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    private lazy var priceDescriptionHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        return stackView
    }()

    private lazy var priceDescriptionTitle: UILabel = {
        let label = UILabel()
        label.text = "Cheap price"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()

    private lazy var priceDescriptionSubtitle: UILabel = {
        let label = UILabel()
        label.text = "only 99"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()

    private lazy var priceDescriptionSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    // MARK: - End of Text Description View

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        self.mainContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.mainVerticalStackView.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(mainContainerView)
        self.mainContainerView.addSubview(mainVerticalStackView)
        self.mainVerticalStackView.addArrangedSubview(mainHorizontalStackView)
        self.mainHorizontalStackView.addArrangedSubview(selectedDotHorizontalStackView)
        self.mainHorizontalStackView.addArrangedSubview(selectedDotVerticalStackView)
        self.selectedDotHorizontalStackView.addArrangedSubview(selectedDotImageView)

        self.mainHorizontalStackView.addArrangedSubview(productDescriptionHorizontalStackView)
        self.productDescriptionHorizontalStackView.addArrangedSubview(productDescriptionVerticalStackView)
        self.productDescriptionVerticalStackView.addArrangedSubview(productDescriptionTitle)
        self.productDescriptionVerticalStackView.addArrangedSubview(productDescriptionSubtitle)
        self.productDescriptionHorizontalStackView.addArrangedSubview(productDescriptionSpacer)

        self.mainHorizontalStackView.addArrangedSubview(descriptionToPriceSpacer)

        self.mainHorizontalStackView.addArrangedSubview(priceDescriptionHorizontalStackView)
        self.priceDescriptionHorizontalStackView.addArrangedSubview(priceDescriptionVerticalStackView)
        self.priceDescriptionHorizontalStackView.addArrangedSubview(self.priceDescriptionSpacer)
        self.priceDescriptionVerticalStackView.addArrangedSubview(priceDescriptionTitle)
        self.priceDescriptionVerticalStackView.addArrangedSubview(priceDescriptionSubtitle)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            mainVerticalStackView.topAnchor.constraint(equalTo: mainContainerView.topAnchor, constant: 4),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor),
            mainVerticalStackView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),

            self.selectedDotHorizontalStackView.widthAnchor.constraint(equalToConstant: 13),
            self.selectedDotImageView.heightAnchor.constraint(equalToConstant: 13),
        ])
    }
}

