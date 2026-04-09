#if canImport(UIKit)
import UIKit

// MARK: - VxV4PaywallProductCell
// ============================================================================
// V4 Product Cell — Apple Guideline 3.1.2(c) Compliant
// ============================================================================
//
// PURPOSE:
//   Replaces VxV3PaywallProductCell. The V3 cell was rejected by Apple because
//   it promoted the free trial more prominently than the billed price.
//
// V3 VIOLATIONS (what was wrong):
//   - "FREE for 7 Days" was 13pt BOLD in ACCENT COLOR — most eye-catching
//   - "then $9.99/month" was 13pt regular in muted gray — subordinate
//   - CTA button said "Try Free for 7 Days" with NO price at all
//
// V4 FIXES (Apple 3.1.2(c) compliance):
//   - Billed price ("$9.99/month") is 16pt BOLD in PRIMARY text color — MOST PROMINENT
//   - Plan name ("Monthly") is 15pt semibold in primary color — secondary prominence
//   - Trial info ("Includes 7-day free trial") is 12pt REGULAR in MUTED GRAY — subordinate
//   - Trial text NEVER uses accent/brand color
//   - Trial text NEVER uses bold weight
//   - If no free trial → bottom row is completely hidden, cell height shrinks 72→56pt
//
// CELL LAYOUT:
//   ┌─────────────────────────────────────────────────┐
//   │  ◉  Monthly                      $9.99/month    │  ← top row (plan + price)
//   │     Includes 7-day free trial                   │  ← bottom row (trial, muted)
//   └─────────────────────────────────────────────────┘
//
//   ┌─────────────────────────────────────────────────┐
//   │  ◉  Yearly                      $49.99/year     │
//   │     $4.17/mo · Includes 7-day free trial        │  ← monthly equiv + trial
//   └─────────────────────────────────────────────────┘
//
// DYNAMIC HEIGHT:
//   - 72pt when bottom row is visible (has trial OR has monthly equivalent for yearly)
//   - 56pt when bottom row is hidden (no trial, not yearly)
//   - Use static method `hasSecondRow(for:)` to determine height before cell creation
//
// DATA MODEL FIELDS USED:
//   - model.localizedPrice → billed price string (e.g. "$9.99")
//   - model.subPeriod?.singlePeriodString → period text (e.g. "month")
//   - model.subPeriod?.periodString → plan name (e.g. "Monthly")
//   - model.monthlyPrice → monthly equivalent for yearly plans (e.g. "$4.17")
//   - model.freeTrialUnit → trial duration in days (Int, always converted to days)
//   - model.eligibleForFreeTrialOrDiscount → whether user can get free trial
//   - model.isBestOffer → shows "BEST VALUE" badge
//   - model.isSelected → selected state (radio button + border)
//   - model.isLightMode → light/dark appearance
//   - model.textColor → primary text color
//   - model.font → VxFont for all labels
//
// LOCALIZATION KEYS:
//   - "Subscription_V4_TrialIncludedLabel" → "Includes {xxxTrialDuration} free trial"
//   - "Subscription_V4_PerMonthLabel" → "{xxxPrice}/mo"
//   - "Subscription_V3_BestValueBadge" → "BEST VALUE" (reused from V3)
// ============================================================================

final class VxV4PaywallProductCell: VxNiblessTableViewCell {

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
        label.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return label
    }()

    // MARK: - Radio Button
    private lazy var radioImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Plan Name (left top) — 15pt semibold, primary color
    private lazy var planNameLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Billed Price (right top) — 16pt bold, primary color — MOST PROMINENT
    private lazy var billedPriceLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()

    // MARK: - Trial Info (bottom row) — 12pt regular, muted/secondary — SUBORDINATE
    private lazy var trialInfoLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Layout Stacks
    private lazy var topRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    private lazy var bottomRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
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
        topRowStack.addArrangedSubview(billedPriceLabel)

        bottomRowStack.addArrangedSubview(trialInfoLabel)

        planNameLabel.setContentHuggingPriority(.required, for: .horizontal)
        planNameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        billedPriceLabel.setContentHuggingPriority(.required, for: .horizontal)
        billedPriceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
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

            bestValueBadge.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            bestValueBadge.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -12),
            bestValueBadge.heightAnchor.constraint(equalToConstant: 18)
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

        let secondaryColor = model.isLightMode ? UIColor(white: 0.5, alpha: 1.0) : UIColor(white: 0.5, alpha: 1.0)

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

        // Plan name — 15pt semibold, primary text color
        planNameLabel.setFont(font, size: 15, weight: .semibold)
        planNameLabel.textColor = model.textColor
        planNameLabel.text = model.subPeriod?.periodString ?? ""

        // Billed price — 16pt bold, primary text color — THE MOST PROMINENT ELEMENT (Apple 3.1.2(c))
        billedPriceLabel.setFont(font, size: 16, weight: .bold)
        billedPriceLabel.textColor = model.textColor
        let priceText = "\(model.localizedPrice ?? "")/\(model.subPeriod?.singlePeriodString ?? "")"
        billedPriceLabel.text = priceText

        // Trial info — 12pt regular, muted/secondary color — SUBORDINATE (Apple 3.1.2(c))
        let hasFreeTrial = (model.freeTrialUnit ?? 0) > 0 && model.eligibleForFreeTrialOrDiscount == true
        if hasFreeTrial {
            trialInfoLabel.setFont(font, size: 12, weight: .regular)
            trialInfoLabel.textColor = secondaryColor

            var trialParts: [String] = []

            // Monthly equivalent for yearly plans
            if let monthlyPrice = model.monthlyPrice, model.subPeriod == .year {
                let perMonthTemplate = localizeFallback("Subscription_V4_PerMonthLabel", default: "{xxxPrice}/mo")
                let perMonthText = perMonthTemplate.replacingOccurrences(of: "{xxxPrice}", with: monthlyPrice)
                trialParts.append(perMonthText)
            }

            // Free trial text
            let trialString = trialDurationString(days: model.freeTrialUnit!)
            let trialTemplate = localizeFallback("Subscription_V4_TrialIncludedLabel", default: "Includes {xxxTrialDuration} free trial")
            let trialText = trialTemplate.replacingOccurrences(of: "{xxxTrialDuration}", with: trialString)
            trialParts.append(trialText)

            trialInfoLabel.text = trialParts.joined(separator: " · ")
            trialInfoLabel.isHidden = false
            bottomRowStack.isHidden = false
        } else if let monthlyPrice = model.monthlyPrice, model.subPeriod == .year {
            // No free trial but yearly plan — show monthly equivalent
            trialInfoLabel.setFont(font, size: 12, weight: .regular)
            trialInfoLabel.textColor = secondaryColor
            let perMonthTemplate = localizeFallback("Subscription_V4_PerMonthLabel", default: "{xxxPrice}/mo")
            trialInfoLabel.text = perMonthTemplate.replacingOccurrences(of: "{xxxPrice}", with: monthlyPrice)
            trialInfoLabel.isHidden = false
            bottomRowStack.isHidden = false
        } else {
            trialInfoLabel.isHidden = true
            bottomRowStack.isHidden = true
        }

        // Best value badge
        bestValueBadge.isHidden = !model.isBestOffer
        bestValueBadge.setFont(font, size: 9, weight: .bold)
        let badgeText = localizeFallback("Subscription_V3_BestValueBadge", default: "BEST VALUE")
        bestValueBadge.text = "  \(badgeText)  "
        bestValueBadge.backgroundColor = accentColor
    }

    /// Returns whether this cell should show a second row (for dynamic height)
    static func hasSecondRow(for model: VxMainSubscriptionDataSourceModel) -> Bool {
        let hasFreeTrial = (model.freeTrialUnit ?? 0) > 0 && model.eligibleForFreeTrialOrDiscount == true
        let hasMonthlyEquivalent = model.monthlyPrice != nil && model.subPeriod == .year
        return hasFreeTrial || hasMonthlyEquivalent
    }

    private func localizeFallback(_ key: String, default defaultValue: String) -> String {
        let localized = key.localize()
        return localized == key ? defaultValue : localized
    }

    /// Converts day count to a human-readable duration string (e.g. 30 → "1 Month", 7 → "7 Days")
    private func trialDurationString(days: Int) -> String {
        if days >= 365 && days % 365 == 0 {
            let years = days / 365
            return years == 1 ? "1 Year" : "\(years) Years"
        } else if days >= 28 && days % 30 == 0 {
            let months = days / 30
            return months == 1 ? "1 Month" : "\(months) Months"
        } else if days >= 7 && days % 7 == 0 {
            let weeks = days / 7
            return weeks == 1 ? "1 Week" : "\(weeks) Weeks"
        } else {
            return days == 1 ? "1 Day" : "\(days) Days"
        }
    }
}
#endif
