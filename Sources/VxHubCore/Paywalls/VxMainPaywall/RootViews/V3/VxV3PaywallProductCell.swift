#if canImport(UIKit)
import UIKit

final class VxV3PaywallProductCell: VxNiblessTableViewCell {

    private var model: VxMainSubscriptionDataSourceModel?
    private var accentColor: UIColor = .systemBlue

    // MARK: - Container
    private lazy var cardContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.clipsToBounds = true
        return view
    }()

    // MARK: - Best Value Badge
    private lazy var bestValueBadge: VxLabel = {
        let label = VxLabel()
        label.textAlignment = .center
        label.textColor = .white
        label.clipsToBounds = true
        label.layer.cornerRadius = 4
        return label
    }()

    // MARK: - Radio Button
    private lazy var radioImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Plan Name (left top)
    private lazy var planNameLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Free Trial Label (right top, accent color)
    private lazy var freeTrialLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()

    // MARK: - Price After Trial (left bottom)
    private lazy var priceAfterTrialLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Per Month Price (right bottom)
    private lazy var perMonthLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()

    // MARK: - Layout Stacks
    private lazy var topRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private lazy var bottomRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private lazy var verticalContentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

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
        bestValueBadge.translatesAutoresizingMaskIntoConstraints = false
        radioImageView.translatesAutoresizingMaskIntoConstraints = false
        verticalContentStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(cardContainerView)
        cardContainerView.addSubview(radioImageView)
        cardContainerView.addSubview(verticalContentStack)
        cardContainerView.addSubview(bestValueBadge)

        verticalContentStack.addArrangedSubview(topRowStack)
        verticalContentStack.addArrangedSubview(bottomRowStack)

        topRowStack.addArrangedSubview(planNameLabel)
        topRowStack.addArrangedSubview(UIView.flexibleSpacer())
        topRowStack.addArrangedSubview(freeTrialLabel)

        bottomRowStack.addArrangedSubview(priceAfterTrialLabel)
        bottomRowStack.addArrangedSubview(UIView.flexibleSpacer())
        bottomRowStack.addArrangedSubview(perMonthLabel)

        planNameLabel.setContentHuggingPriority(.required, for: .horizontal)
        freeTrialLabel.setContentHuggingPriority(.required, for: .horizontal)
        priceAfterTrialLabel.setContentHuggingPriority(.required, for: .horizontal)
        perMonthLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            radioImageView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 16),
            radioImageView.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor),
            radioImageView.widthAnchor.constraint(equalToConstant: 22),
            radioImageView.heightAnchor.constraint(equalToConstant: 22),

            verticalContentStack.leadingAnchor.constraint(equalTo: radioImageView.trailingAnchor, constant: 12),
            verticalContentStack.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16),
            verticalContentStack.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor),

            bestValueBadge.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: -1),
            bestValueBadge.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -12),
            bestValueBadge.heightAnchor.constraint(equalToConstant: 20),
            bestValueBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }

    // MARK: - Configure
    func configure(
        with model: VxMainSubscriptionDataSourceModel,
        accentColor: UIColor
    ) {
        self.model = model
        self.accentColor = accentColor
        guard let font = model.font else { return }

        // Card border
        let borderColor: UIColor = model.isSelected ? accentColor : (model.isLightMode ? UIColor(white: 0.82, alpha: 1.0) : UIColor(white: 0.3, alpha: 1.0))
        cardContainerView.layer.borderColor = borderColor.cgColor
        cardContainerView.backgroundColor = model.isLightMode ? UIColor(white: 0.97, alpha: 1.0) : UIColor(white: 0.1, alpha: 1.0)

        // Radio
        if model.isSelected {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            radioImageView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
            radioImageView.tintColor = accentColor
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            radioImageView.image = UIImage(systemName: "circle", withConfiguration: config)
            radioImageView.tintColor = model.isLightMode ? UIColor(white: 0.7, alpha: 1.0) : UIColor(white: 0.4, alpha: 1.0)
        }

        // Plan name
        planNameLabel.setFont(font, size: 16, weight: .semibold)
        planNameLabel.textColor = model.textColor
        planNameLabel.text = model.subPeriod?.periodString ?? ""

        // Free trial info
        freeTrialLabel.setFont(font, size: 14, weight: .bold)
        freeTrialLabel.textColor = accentColor
        if let freeTrialUnit = model.freeTrialUnit, freeTrialUnit > 0,
           model.eligibleForFreeTrialOrDiscount == true {
            let trialString = model.freeTrialPeriod?.freeTrialString(value: freeTrialUnit) ?? "\(freeTrialUnit)"
            let freeForDays = VxLocalizables.Subscription.V3.freeForDaysLabel
                .replacingOccurrences(of: "{xxxTrialDuration}", with: trialString)
            freeTrialLabel.text = freeForDays
            freeTrialLabel.isHidden = false
        } else {
            freeTrialLabel.isHidden = true
        }

        // Price after trial
        priceAfterTrialLabel.setFont(font, size: 13, weight: .regular)
        priceAfterTrialLabel.textColor = model.isLightMode ? UIColor(white: 0.4, alpha: 1.0) : UIColor(white: 0.6, alpha: 1.0)
        let thenText = VxLocalizables.Subscription.V3.thenPriceLabel
            .replacingOccurrences(of: "{xxxPrice}", with: model.localizedPrice ?? "")
            .replacingOccurrences(of: "{xxxPeriod}", with: model.subPeriod?.periodText ?? "")
        priceAfterTrialLabel.text = thenText

        // Per month price (show only for yearly/weekly plans where a comparison makes sense)
        perMonthLabel.setFont(font, size: 12, weight: .medium)
        perMonthLabel.textColor = model.isLightMode ? UIColor(white: 0.5, alpha: 1.0) : UIColor(white: 0.5, alpha: 1.0)
        if let monthlyPrice = model.monthlyPrice, model.subPeriod == .year {
            perMonthLabel.text = VxLocalizables.Subscription.V3.perMonthLabel
                .replacingOccurrences(of: "{xxxPrice}", with: monthlyPrice)
            perMonthLabel.isHidden = false
        } else {
            perMonthLabel.isHidden = true
        }

        // Best value badge
        bestValueBadge.isHidden = !model.isBestOffer
        bestValueBadge.setFont(font, size: 10, weight: .bold)
        bestValueBadge.text = "  \(VxLocalizables.Subscription.V3.bestValueBadge)  "
        bestValueBadge.backgroundColor = accentColor
    }
}
#endif
