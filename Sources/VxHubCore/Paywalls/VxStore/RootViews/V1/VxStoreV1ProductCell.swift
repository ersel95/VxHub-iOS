#if canImport(UIKit)
import UIKit

final class VxStoreV1ProductCell: VxNiblessCollectionViewCell {

    private var model: VxStoreDataSourceModel?
    private var buyAction: ((String) -> Void)?

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

    // MARK: - Title
    private lazy var titleLabel: VxLabel = {
        let label = VxLabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    // MARK: - Bonus
    private lazy var bonusLabel: VxLabel = {
        let label = VxLabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Buy Button / Price Label
    private lazy var buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Owned Overlay
    private lazy var ownedBadge: VxLabel = {
        let label = VxLabel()
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 6
        return label
    }()

    // MARK: - Card Container
    private lazy var cardContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.distribution = .fill
        return stack
    }()

    @objc private func buyButtonTapped() {
        guard let model = model, !model.isAlreadyPurchased else { return }
        buyAction?(model.identifier)
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        ownedBadge.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(cardContainerView)
        cardContainerView.addSubview(contentStack)
        cardContainerView.addSubview(badgeLabel)
        cardContainerView.addSubview(ownedBadge)

        contentStack.addArrangedSubview(UIView.spacer(height: 8))
        contentStack.addArrangedSubview(productImageView)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(bonusLabel)
        contentStack.addArrangedSubview(buyButton)
        contentStack.addArrangedSubview(UIView.spacer(height: 4))
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            contentStack.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 8),
            contentStack.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -4),
            contentStack.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 8),
            contentStack.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -8),

            badgeLabel.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            badgeLabel.centerXAnchor.constraint(equalTo: cardContainerView.centerXAnchor),
            badgeLabel.heightAnchor.constraint(equalToConstant: 18),

            ownedBadge.centerXAnchor.constraint(equalTo: cardContainerView.centerXAnchor),
            ownedBadge.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor),

            buyButton.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 4),
            buyButton.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -4),
            buyButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    // MARK: - Configure
    func configure(
        with model: VxStoreDataSourceModel,
        configuration: VxStoreV1Configuration,
        buyAction: @escaping (String) -> Void
    ) {
        self.model = model
        self.buyAction = buyAction
        let font = model.font

        // Card appearance
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
        productImageView.constraints.forEach { productImageView.removeConstraint($0) }
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
        titleLabel.setFont(font, size: 15, weight: .bold)
        titleLabel.textColor = model.textColor
        titleLabel.text = model.title

        // Bonus
        if configuration.showBonusLabel, let bonus = model.initialBonus, bonus > 0 {
            bonusLabel.setFont(font, size: 12, weight: .semibold)
            bonusLabel.textColor = configuration.bonusLabelColor
            bonusLabel.text = "+\(bonus)% Bonus"
            bonusLabel.isHidden = false
        } else {
            bonusLabel.isHidden = true
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
        if configuration.purchaseMode == .perCard {
            buyButton.isHidden = false
            buyButton.setTitle(model.localizedPrice, for: .normal)
            buyButton.titleLabel?.font = .custom(font, size: 14, weight: .bold)
            buyButton.setTitleColor(configuration.buyButtonTextColor, for: .normal)
            buyButton.backgroundColor = configuration.buyButtonColor
            buyButton.layer.cornerRadius = configuration.buyButtonCornerRadius
            buyButton.clipsToBounds = true
        } else {
            // selectAndBuy: show price as label
            buyButton.isHidden = false
            buyButton.setTitle(model.localizedPrice, for: .normal)
            buyButton.titleLabel?.font = .custom(font, size: 14, weight: .semibold)
            buyButton.setTitleColor(model.textColor, for: .normal)
            buyButton.backgroundColor = .clear
            buyButton.isUserInteractionEnabled = false
        }

        // Owned state
        if model.isAlreadyPurchased {
            ownedBadge.isHidden = false
            ownedBadge.setFont(font, size: 11, weight: .bold)
            ownedBadge.text = "  \(configuration.purchasedBadgeText ?? "OWNED")  "
            ownedBadge.backgroundColor = configuration.purchasedBadgeColor
            ownedBadge.textColor = .white
            buyButton.isEnabled = false
            buyButton.alpha = 0.5
            contentView.alpha = 0.7
        } else {
            ownedBadge.isHidden = true
            buyButton.isEnabled = true
            buyButton.alpha = 1.0
            contentView.alpha = 1.0
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        badgeLabel.isHidden = true
        bonusLabel.isHidden = true
        ownedBadge.isHidden = true
        buyButton.isHidden = false
        buyButton.isEnabled = true
        buyButton.isUserInteractionEnabled = true
        buyButton.alpha = 1.0
        contentView.alpha = 1.0
        productImageView.image = nil
    }
}
#endif
