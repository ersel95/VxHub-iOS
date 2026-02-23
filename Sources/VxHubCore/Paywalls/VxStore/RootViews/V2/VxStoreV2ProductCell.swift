#if canImport(UIKit)
import UIKit

final class VxStoreV2ProductCell: VxNiblessTableViewCell {

    private var model: VxStoreDataSourceModel?
    private var buyAction: ((String) -> Void)?

    // MARK: - Card Container
    private lazy var cardContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    // MARK: - Badge
    private lazy var badgeLabel: VxLabel = {
        let label = VxLabel()
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 4
        label.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return label
    }()

    // MARK: - Product Image
    private lazy var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    // MARK: - Labels
    private lazy var titleLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        return label
    }()

    private lazy var descriptionLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 2
        return label
    }()

    private lazy var bonusLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Feature Stack
    private lazy var featureStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    // MARK: - Buy Button / Price
    private lazy var buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Owned Badge
    private lazy var ownedBadge: VxLabel = {
        let label = VxLabel()
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 6
        return label
    }()

    // MARK: - Layout Stacks
    private lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    private lazy var topRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    @objc private func buyButtonTapped() {
        guard let model = model, !model.isAlreadyPurchased else { return }
        buyAction?(model.identifier)
    }

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        topRowStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        featureStack.translatesAutoresizingMaskIntoConstraints = false
        ownedBadge.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(cardContainerView)
        cardContainerView.addSubview(topRowStack)
        cardContainerView.addSubview(textStack)
        cardContainerView.addSubview(badgeLabel)
        cardContainerView.addSubview(ownedBadge)

        topRowStack.addArrangedSubview(productImageView)
        topRowStack.addArrangedSubview(titleLabel)
        topRowStack.addArrangedSubview(UIView.flexibleSpacer())
        topRowStack.addArrangedSubview(buyButton)

        textStack.addArrangedSubview(descriptionLabel)
        textStack.addArrangedSubview(bonusLabel)
        textStack.addArrangedSubview(featureStack)

        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            topRowStack.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 14),
            topRowStack.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 16),
            topRowStack.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16),

            textStack.topAnchor.constraint(equalTo: topRowStack.bottomAnchor, constant: 6),
            textStack.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: cardContainerView.bottomAnchor, constant: -14),

            productImageView.widthAnchor.constraint(equalToConstant: 36),
            productImageView.heightAnchor.constraint(equalToConstant: 36),

            buyButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            buyButton.heightAnchor.constraint(equalToConstant: 32),

            badgeLabel.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            badgeLabel.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -12),
            badgeLabel.heightAnchor.constraint(equalToConstant: 18),

            ownedBadge.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16),
            ownedBadge.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor)
        ])
    }

    // MARK: - Configure
    func configure(
        with model: VxStoreDataSourceModel,
        configuration: VxStoreV2Configuration,
        buyAction: @escaping (String) -> Void
    ) {
        self.model = model
        self.buyAction = buyAction
        let font = model.font

        // Card
        cardContainerView.backgroundColor = configuration.cardBackgroundColor
        cardContainerView.layer.cornerRadius = configuration.cardCornerRadius

        if model.isSelected && configuration.purchaseMode == .selectAndBuy {
            cardContainerView.layer.borderColor = configuration.selectedCardBorderColor.cgColor
            cardContainerView.layer.borderWidth = configuration.selectedCardBorderWidth
        } else {
            cardContainerView.layer.borderColor = configuration.cardBorderColor.cgColor
            cardContainerView.layer.borderWidth = configuration.cardBorderWidth
        }

        // Product image
        let imgSize = configuration.productImageSize
        productImageView.constraints.filter { $0.firstAttribute == .width || $0.firstAttribute == .height }.forEach {
            productImageView.removeConstraint($0)
        }
        NSLayoutConstraint.activate([
            productImageView.widthAnchor.constraint(equalToConstant: imgSize),
            productImageView.heightAnchor.constraint(equalToConstant: imgSize)
        ])

        if let imageName = model.productImageName {
            if let sfImage = UIImage(systemName: imageName) {
                productImageView.image = sfImage
                productImageView.tintColor = configuration.buyButtonColor
            } else if let namedImage = UIImage(named: imageName) {
                productImageView.image = namedImage
            }
        }

        // Title
        titleLabel.setFont(font, size: 16, weight: .semibold)
        titleLabel.textColor = model.textColor
        titleLabel.text = model.title

        // Description
        if configuration.showProductDescription && !model.description.isEmpty {
            descriptionLabel.setFont(font, size: 13, weight: .regular)
            descriptionLabel.textColor = model.isLightMode ? UIColor(white: 0.4, alpha: 1.0) : UIColor(white: 0.6, alpha: 1.0)
            descriptionLabel.text = model.description
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }

        // Bonus
        if configuration.showBonusLabel, let bonus = model.initialBonus, bonus > 0 {
            bonusLabel.setFont(font, size: 12, weight: .semibold)
            bonusLabel.textColor = configuration.bonusLabelColor
            bonusLabel.text = "+\(bonus)% Bonus"
            bonusLabel.isHidden = false
        } else {
            bonusLabel.isHidden = true
        }

        // Features
        featureStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let features = configuration.productFeatures[model.identifier] {
            for feature in features {
                let row = makeFeatureRow(icon: feature.icon, text: feature.text, font: font, textColor: model.textColor, accentColor: configuration.buyButtonColor)
                featureStack.addArrangedSubview(row)
            }
            featureStack.isHidden = false
        } else {
            featureStack.isHidden = true
        }

        // Badge
        if let badgeText = model.badgeText {
            badgeLabel.setFont(font, size: 9, weight: .bold)
            badgeLabel.text = "  \(badgeText)  "
            badgeLabel.backgroundColor = model.badgeColor ?? configuration.buyButtonColor
            badgeLabel.textColor = model.badgeTextColor ?? .white
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }

        // Buy button
        if configuration.purchaseMode == .perCard && !model.isAlreadyPurchased {
            buyButton.isHidden = false
            buyButton.setTitle(model.localizedPrice, for: .normal)
            buyButton.titleLabel?.font = .custom(font, size: 14, weight: .bold)
            buyButton.setTitleColor(configuration.buyButtonTextColor, for: .normal)
            buyButton.backgroundColor = configuration.buyButtonColor
            buyButton.layer.cornerRadius = configuration.buyButtonCornerRadius
            buyButton.clipsToBounds = true
            buyButton.isUserInteractionEnabled = true
        } else if configuration.purchaseMode == .selectAndBuy {
            buyButton.isHidden = false
            buyButton.setTitle(model.localizedPrice, for: .normal)
            buyButton.titleLabel?.font = .custom(font, size: 14, weight: .semibold)
            buyButton.setTitleColor(model.textColor, for: .normal)
            buyButton.backgroundColor = .clear
            buyButton.isUserInteractionEnabled = false
        } else {
            buyButton.isHidden = true
        }

        // Owned
        if model.isAlreadyPurchased {
            ownedBadge.isHidden = false
            ownedBadge.setFont(font, size: 11, weight: .bold)
            ownedBadge.text = "  \(configuration.purchasedBadgeText ?? "OWNED")  "
            ownedBadge.backgroundColor = configuration.purchasedBadgeColor
            ownedBadge.textColor = .white
            buyButton.isHidden = true
            contentView.alpha = 0.7
        } else {
            ownedBadge.isHidden = true
            contentView.alpha = 1.0
        }
    }

    private func makeFeatureRow(icon: String, text: String, font: VxFont, textColor: UIColor, accentColor: UIColor) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 6
        row.alignment = .center

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let sfImage = UIImage(systemName: icon) {
            imageView.image = sfImage
            imageView.tintColor = accentColor
        } else if let namedImage = UIImage(named: icon) {
            imageView.image = namedImage
        }
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 16)
        ])

        let label = VxLabel()
        label.text = text
        label.setFont(font, size: 12, weight: .medium)
        label.textColor = textColor
        label.numberOfLines = 1

        row.addArrangedSubview(imageView)
        row.addArrangedSubview(label)
        return row
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        badgeLabel.isHidden = true
        bonusLabel.isHidden = true
        descriptionLabel.isHidden = true
        ownedBadge.isHidden = true
        buyButton.isHidden = false
        buyButton.isUserInteractionEnabled = true
        contentView.alpha = 1.0
        productImageView.image = nil
        featureStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
#endif
