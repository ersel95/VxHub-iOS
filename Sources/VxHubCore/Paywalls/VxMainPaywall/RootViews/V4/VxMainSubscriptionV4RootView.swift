#if canImport(UIKit)
import UIKit
import Combine

// MARK: - VxMainSubscriptionV4RootView
// ============================================================================
// V4 Paywall Root View — Apple Guideline 3.1.2(c) Compliant
// ============================================================================
//
// PURPOSE:
//   Main scroll view for the V4 paywall. Layout is identical to V3 except:
//   1. Uses VxV4PaywallProductCell instead of VxV3PaywallProductCell
//   2. CTA button ALWAYS includes the billed price in its text
//   3. Product table row heights are dynamic (72pt with trial, 56pt without)
//
// SCROLL LAYOUT (top to bottom):
//   1. Close button (top-left, overlay, respects closeButtonDelay)
//   2. Rating section (stars + value + count) — conditional on ratingValue != nil
//   3. Hero image — conditional on heroImageName != nil
//   4. Headline (26pt bold)
//   5. Subtitle (16pt regular, secondary color)
//   6. Feature list (icon + text rows)
//   7. Products TableView (VxV4PaywallProductCell — the compliance-fixed cell)
//   8. CTA Button (ALWAYS shows price — "Start Free Trial — then $9.99/month"
//      or "Subscribe for $9.99/month")
//   9. Trust line (lock icon + text)
//  10. Footer links (Restore | Terms | Privacy | Redeem)
//
// CTA BUTTON TEXT LOGIC (updateCTAText):
//   if product has eligible free trial:
//     → "Start Free Trial — then {localizedPrice}/{period}"
//     → Example: "Start Free Trial — then $9.99/month"
//   else:
//     → "Subscribe for {localizedPrice}/{period}"
//     → Example: "Subscribe for $9.99/month"
//
// LOCALIZATION KEYS (V4-specific):
//   - "Subscription_V4_CTATrialLabel" → "Start Free Trial — then {xxxPrice}/{xxxPeriod}"
//   - "Subscription_V4_CTASubscribeLabel" → "Subscribe for {xxxPrice}/{xxxPeriod}"
//   - "Subscription_V4_TrialIncludedLabel" → "Includes {xxxTrialDuration} free trial"
//   - "Subscription_V4_PerMonthLabel" → "{xxxPrice}/mo"
//   All keys use fallback pattern: localize() returns key → use hardcoded English default
//
// INTEGRATION CHAIN:
//   VxHub.shared.showPaywallV4(config)
//     → creates VxMainPaywallConfiguration(paywallType: .v4)
//     → creates VxMainSubscriptionViewModel, sets vm.v4Configuration = config
//     → presents VxMainSubscriptionViewController
//       → loadView() checks paywallType == .v4
//       → instantiates VxMainSubscriptionV4RootView(viewModel:, v4Configuration:)
//
// SHARED COMPONENTS (do NOT modify):
//   - VxMainSubscriptionViewModel — handles purchase, restore, product selection
//   - VxMainSubscriptionDataSourceModel — product data model
//   - VxPaywallUtil — fetches/processes RevenueCat products
//   - VxLoadingButton — button with isLoading spinner
//   - VxLabel — custom label with VxFont support
//   - VxNiblessView — programmatic base class (no XIB/Storyboard)
// ============================================================================

final public class VxMainSubscriptionV4RootView: VxNiblessView {

    private let viewModel: VxMainSubscriptionViewModel
    private let v4Config: VxMainPaywallV4Configuration

    private var dataSource: UITableViewDiffableDataSource<VxMainSubscriptionDataSourceSection, VxMainSubscriptionDataSourceModel>?
    private var disposeBag = Set<AnyCancellable>()
    nonisolated(unsafe) private var closeButtonTimer: Timer?

    // MARK: - Scroll View
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        return stack
    }()

    // MARK: - Close Button
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)?
            .withTintColor(v4Config.closeButtonColor, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = v4Config.isLightMode ? UIColor(white: 0.9, alpha: 1.0) : UIColor(white: 0.2, alpha: 1.0)
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc private func closeButtonTapped() {
        guard viewModel.loadingStatePublisher.value == false else { return }
        viewModel.dismiss()
    }

    // MARK: - Rating Section
    private lazy var ratingContainerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        stack.distribution = .fill
        return stack
    }()

    private lazy var ratingStarsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        return stack
    }()

    private lazy var ratingValueLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        return label
    }()

    private lazy var ratingCountLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Hero Section
    private lazy var heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var headlineLabel: VxLabel = {
        let label = VxLabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtitleLabel: VxLabel = {
        let label = VxLabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Feature List
    private lazy var featureStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()

    // MARK: - Products Table
    private lazy var productsTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.separatorStyle = .none
        table.isScrollEnabled = false
        return table
    }()

    private var productsTableHeightConstraint: NSLayoutConstraint?

    // MARK: - CTA Button
    private lazy var ctaButton: VxLoadingButton = {
        let button = VxLoadingButton(type: .system)
        button.titleLabel?.font = .custom(v4Config.font, size: 17, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(ctaButtonTapped), for: .touchUpInside)
        return button
    }()

    private var ctaGradientLayer: CAGradientLayer?

    @objc private func ctaButtonTapped() {
        viewModel.purchaseAction()
    }

    // MARK: - Trust Line
    private lazy var trustLineStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        return stack
    }()

    private lazy var trustLockIcon: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        imageView.image = UIImage(systemName: "lock.shield.fill", withConfiguration: config)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var trustLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    // MARK: - Footer
    private lazy var footerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()

    private lazy var restoreButton: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.restorePurchaseLabel
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(restoreButtonTapped))
        label.addGestureRecognizer(tap)
        return label
    }()

    private lazy var termsButton: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.termsOfUse
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(termsButtonTapped))
        label.addGestureRecognizer(tap)
        return label
    }()

    private lazy var privacyButton: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.privacyPol
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(privacyButtonTapped))
        label.addGestureRecognizer(tap)
        return label
    }()

    private lazy var redeemButton: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.reedemCode
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(redeemButtonTapped))
        label.addGestureRecognizer(tap)
        return label
    }()

    @objc private func restoreButtonTapped() {
        guard viewModel.loadingStatePublisher.value == false else { return }
        viewModel.restoreAction()
    }

    @objc private func termsButtonTapped() {
        VxHub.shared.showEula(isFullScreen: false, showCloseButton: true)
    }

    @objc private func privacyButtonTapped() {
        VxHub.shared.showPrivacy(isFullScreen: false, showCloseButton: true)
    }

    @objc private func redeemButtonTapped() {
        viewModel.onReedemCodaButtonTapped?()
    }

    // MARK: - Init
    public init(frame: CGRect = .zero, viewModel: VxMainSubscriptionViewModel, v4Configuration: VxMainPaywallV4Configuration) {
        self.viewModel = viewModel
        self.v4Config = v4Configuration
        super.init(frame: frame)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.setupUI()
            self.constructHierarchy()
            self.setupTableDataSource()
            self.applySnapshot()
            self.setupBindables()
            self.setupCloseButtonDelay()
        }
    }

    deinit {
        closeButtonTimer?.invalidate()
    }

    // MARK: - Setup
    private func setupUI() {
        self.backgroundColor = v4Config.backgroundColor

        let textColor = v4Config.textColor
        let secondaryColor = v4Config.isLightMode ? UIColor(white: 0.45, alpha: 1.0) : UIColor(white: 0.55, alpha: 1.0)
        let footerColor = v4Config.isLightMode ? UIColor(white: 0.45, alpha: 1.0) : UIColor(white: 0.4, alpha: 1.0)

        // Rating section
        if let ratingValue = v4Config.ratingValue {
            setupStars(rating: Double(ratingValue) ?? 4.5)
            ratingValueLabel.setFont(v4Config.font, size: 15, weight: .bold)
            ratingValueLabel.textColor = textColor
            ratingValueLabel.text = ratingValue

            ratingCountLabel.setFont(v4Config.font, size: 14, weight: .regular)
            ratingCountLabel.textColor = secondaryColor
            if let count = v4Config.ratingCount {
                ratingCountLabel.text = "(\(count))"
            }
            ratingContainerStack.isHidden = false
        } else {
            ratingContainerStack.isHidden = true
        }

        // Hero image
        if let heroName = v4Config.heroImageName, !heroName.isEmpty {
            heroImageView.image = UIImage(named: heroName)
            heroImageView.isHidden = (heroImageView.image == nil)
        } else {
            heroImageView.isHidden = true
        }

        // Headline
        headlineLabel.setFont(v4Config.font, size: 26, weight: .bold)
        headlineLabel.textColor = textColor
        headlineLabel.text = v4Config.headlineText ?? fallback("Subscription_V3_HeadlineLabel", default: "Unlock Full Access")

        // Subtitle
        subtitleLabel.setFont(v4Config.font, size: 16, weight: .regular)
        subtitleLabel.textColor = secondaryColor
        subtitleLabel.text = v4Config.subtitleText ?? fallback("Subscription_V3_SubtitleLabel", default: "Start your free trial today")

        // Feature items
        let checkColor = v4Config.ctaButtonColor
        for item in v4Config.featureItems {
            let featureRow = makeFeatureRow(icon: item.icon, text: item.text, textColor: textColor, iconColor: checkColor)
            featureStackView.addArrangedSubview(featureRow)
        }

        // CTA button
        setupCTAButtonColors()

        // Trust line
        trustLockIcon.tintColor = secondaryColor
        trustLabel.setFont(v4Config.font, size: 13, weight: .medium)
        trustLabel.textColor = secondaryColor
        trustLabel.text = v4Config.trustText ?? fallback("Subscription_V3_TrustLineLabel", default: "No payment now · Cancel anytime")

        // Footer buttons
        [restoreButton, termsButton, privacyButton, redeemButton].forEach { label in
            label.setFont(v4Config.font, size: 12, weight: .medium)
            label.textColor = footerColor
        }
    }

    private func makeFeatureRow(icon: String, text: String, textColor: UIColor, iconColor: UIColor) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let sfImage = UIImage(systemName: icon) {
            imageView.image = sfImage
            imageView.tintColor = iconColor
        } else if let namedImage = UIImage(named: icon) {
            imageView.image = namedImage
        } else if let namedImage = UIImage(named: icon, in: .module, compatibleWith: nil) {
            imageView.image = namedImage
        }
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20)
        ])

        let label = VxLabel()
        label.text = text
        label.setFont(v4Config.font, size: 15, weight: .medium)
        label.textColor = textColor
        label.numberOfLines = 0

        row.addArrangedSubview(imageView)
        row.addArrangedSubview(label)
        return row
    }

    private func setupCTAButtonColors() {
        if let endColor = v4Config.ctaGradientEndColor {
            let gradient = CAGradientLayer()
            gradient.colors = [v4Config.ctaButtonColor.cgColor, endColor.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            ctaButton.layer.insertSublayer(gradient, at: 0)
            self.ctaGradientLayer = gradient
        } else {
            ctaButton.backgroundColor = v4Config.ctaButtonColor
        }
    }

    private func setupStars(rating: Double) {
        ratingStarsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let starColor = UIColor.systemYellow
        let totalStars = 5
        let starSize: CGFloat = 16

        for i in 0..<totalStars {
            let threshold = Double(i) + 1.0
            let symbolName: String
            if rating >= threshold {
                symbolName = "star.fill"
            } else if rating >= threshold - 0.5 {
                symbolName = "star.leadinghalf.filled"
            } else {
                symbolName = "star"
            }
            let iv = UIImageView(image: UIImage(systemName: symbolName))
            iv.tintColor = starColor
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: starSize).isActive = true
            iv.heightAnchor.constraint(equalToConstant: starSize).isActive = true
            ratingStarsStack.addArrangedSubview(iv)
        }
    }

    // MARK: - Hierarchy
    private func constructHierarchy() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        productsTableView.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        trustLockIcon.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)
        addSubview(closeButton)
        scrollView.addSubview(contentStackView)

        productsTableView.delegate = self
        productsTableView.registerCell(cellType: VxV4PaywallProductCell.self)

        // Rating section (centered)
        let ratingCenterStack = centeredContainer(ratingContainerStack)
        ratingContainerStack.addArrangedSubview(ratingStarsStack)
        ratingContainerStack.addArrangedSubview(ratingValueLabel)
        ratingContainerStack.addArrangedSubview(ratingCountLabel)

        // Hero image
        let heroContainer = centeredContainer(heroImageView)

        // Headline + subtitle
        let headlineContainer = paddedHStack(headlineLabel, horizontalPadding: 24)
        let subtitleContainer = paddedHStack(subtitleLabel, horizontalPadding: 24)

        // Feature list (padded)
        let featureContainer = paddedHStack(featureStackView, horizontalPadding: 32)

        // Products table (padded)
        let productsContainer = paddedHStack(productsTableView, horizontalPadding: 24)

        // CTA button (padded)
        let ctaContainer = paddedHStack(ctaButton, horizontalPadding: 24)

        // Trust line (centered)
        let trustCenterStack = centeredContainer(trustLineStack)
        trustLineStack.addArrangedSubview(trustLockIcon)
        trustLineStack.addArrangedSubview(trustLabel)

        // Footer (centered)
        let footerCenterStack = centeredContainer(footerStack)
        footerStack.addArrangedSubview(restoreButton)
        footerStack.addArrangedSubview(separatorLabel())
        footerStack.addArrangedSubview(termsButton)
        footerStack.addArrangedSubview(separatorLabel())
        footerStack.addArrangedSubview(privacyButton)
        if viewModel.configuration.isRedeemCodeEnabled {
            footerStack.addArrangedSubview(separatorLabel())
            footerStack.addArrangedSubview(redeemButton)
        }

        // Build content stack
        contentStackView.addArrangedSubview(UIView.spacer(height: 48))
        contentStackView.addArrangedSubview(ratingCenterStack)
        contentStackView.addArrangedSubview(UIView.spacer(height: 20))
        if !heroImageView.isHidden {
            contentStackView.addArrangedSubview(heroContainer)
            contentStackView.addArrangedSubview(UIView.spacer(height: 16))
        }
        contentStackView.addArrangedSubview(headlineContainer)
        contentStackView.addArrangedSubview(UIView.spacer(height: 8))
        contentStackView.addArrangedSubview(subtitleContainer)
        contentStackView.addArrangedSubview(UIView.spacer(height: 24))
        contentStackView.addArrangedSubview(featureContainer)
        contentStackView.addArrangedSubview(UIView.spacer(height: 24))
        contentStackView.addArrangedSubview(productsContainer)
        contentStackView.addArrangedSubview(UIView.spacer(height: 24))
        contentStackView.addArrangedSubview(ctaContainer)
        contentStackView.addArrangedSubview(UIView.spacer(height: 12))
        contentStackView.addArrangedSubview(trustCenterStack)
        contentStackView.addArrangedSubview(UIView.spacer(height: 20))
        contentStackView.addArrangedSubview(footerCenterStack)
        contentStackView.addArrangedSubview(UIView.spacer(height: 16))

        // Calculate dynamic table height: 72pt per row with trial info, 56pt without
        let tableHeight = calculateTableHeight()
        let heightConstraint = productsTableView.heightAnchor.constraint(equalToConstant: tableHeight)
        self.productsTableHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),

            heroImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 120),

            heightConstraint,

            ctaButton.heightAnchor.constraint(equalToConstant: 54),

            trustLockIcon.widthAnchor.constraint(equalToConstant: 14),
            trustLockIcon.heightAnchor.constraint(equalToConstant: 14)
        ])

        restoreButton.setContentHuggingPriority(.required, for: .horizontal)
        termsButton.setContentHuggingPriority(.required, for: .horizontal)
        privacyButton.setContentHuggingPriority(.required, for: .horizontal)
        redeemButton.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func calculateTableHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        for model in viewModel.cellViewModels {
            totalHeight += VxV4PaywallProductCell.hasSecondRow(for: model) ? 72 : 56
        }
        return totalHeight
    }

    // MARK: - Bindables
    private func setupBindables() {
        viewModel.selectedPackagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedPackage in
                guard let self else { return }
                self.updateCTAText(for: selectedPackage)
                self.applySnapshot()
            }
            .store(in: &disposeBag)

        viewModel.loadingStatePublisher
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] isLoading in
                self?.setLoadingState(isLoading)
            }
            .store(in: &disposeBag)
    }

    /// CTA button text ALWAYS includes the billed price — Apple Guideline 3.1.2(c) compliance
    private func updateCTAText(for selectedPackage: VxMainSubscriptionDataSourceModel?) {
        guard let pkg = selectedPackage else { return }
        let priceString = "\(pkg.localizedPrice ?? "")/\(pkg.subPeriod?.singlePeriodString ?? "")"

        if let freeTrialUnit = pkg.freeTrialUnit, freeTrialUnit > 0,
           pkg.eligibleForFreeTrialOrDiscount == true {
            // "Start Free Trial — then $9.99/month"
            let template = fallback("Subscription_V4_CTATrialLabel", default: "Start Free Trial — then {xxxPrice}/{xxxPeriod}")
            let ctaText = template
                .replacingOccurrences(of: "{xxxPrice}", with: pkg.localizedPrice ?? "")
                .replacingOccurrences(of: "{xxxPeriod}", with: pkg.subPeriod?.singlePeriodString ?? "")
            ctaButton.setTitle(ctaText, for: .normal)
        } else {
            // "Subscribe for $9.99/month"
            let template = fallback("Subscription_V4_CTASubscribeLabel", default: "Subscribe for {xxxPrice}/{xxxPeriod}")
            let ctaText = template
                .replacingOccurrences(of: "{xxxPrice}", with: pkg.localizedPrice ?? "")
                .replacingOccurrences(of: "{xxxPeriod}", with: pkg.subPeriod?.singlePeriodString ?? "")
            ctaButton.setTitle(ctaText, for: .normal)
        }
    }

    /// Converts day count to a human-readable duration string (e.g. 30 → "1 Month", 7 → "7 Days", 365 → "1 Year")
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

    private func setLoadingState(_ isLoading: Bool) {
        ctaButton.isLoading = isLoading
        if v4Config.isCloseButtonEnabled {
            closeButton.isEnabled = !isLoading
            closeButton.isHidden = isLoading
        }
    }

    // MARK: - Close Button Delay
    private func setupCloseButtonDelay() {
        if !v4Config.isCloseButtonEnabled {
            closeButton.isHidden = true
            return
        }
        if v4Config.closeButtonDelay > 0 {
            closeButton.isHidden = true
            closeButtonTimer = Timer.scheduledTimer(withTimeInterval: v4Config.closeButtonDelay, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.closeButton.isHidden = false
                    self?.closeButton.alpha = 0
                    UIView.animate(withDuration: 0.3) {
                        self?.closeButton.alpha = 1
                    }
                }
            }
        } else {
            closeButton.isHidden = false
        }
    }

    // MARK: - Table DataSource
    private func setupTableDataSource() {
        dataSource = UITableViewDiffableDataSource(
            tableView: productsTableView,
            cellProvider: { [weak self] tableView, indexPath, model in
                guard let self else { return UITableViewCell() }
                let cell = tableView.dequeueReusableCell(with: VxV4PaywallProductCell.self, for: indexPath)
                cell.selectionStyle = .none
                cell.configure(with: model, accentColor: self.v4Config.ctaButtonColor)
                return cell
            })
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<VxMainSubscriptionDataSourceSection, VxMainSubscriptionDataSourceModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.cellViewModels, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Layout
    override public func layoutSubviews() {
        super.layoutSubviews()
        ctaGradientLayer?.frame = ctaButton.bounds
    }

    // MARK: - Helpers

    private func fallback(_ key: String, default defaultValue: String) -> String {
        let localized = key.localize()
        if localized == key {
            return defaultValue
        }
        return localized
    }

    private func centeredContainer(_ view: UIView) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func paddedHStack(_ view: UIView, horizontalPadding: CGFloat) -> UIStackView {
        let outer = UIStackView()
        outer.axis = .horizontal
        outer.alignment = .fill
        outer.distribution = .fill
        outer.addArrangedSubview(UIView.spacer(width: horizontalPadding))
        outer.addArrangedSubview(view)
        outer.addArrangedSubview(UIView.spacer(width: horizontalPadding))
        return outer
    }

    private func separatorLabel() -> VxLabel {
        let label = VxLabel()
        label.text = " | "
        label.setFont(v4Config.font, size: 12, weight: .medium)
        label.textColor = v4Config.isLightMode ? UIColor(white: 0.45, alpha: 1.0) : UIColor(white: 0.4, alpha: 1.0)
        return label
    }
}

// MARK: - UITableViewDelegate
extension VxMainSubscriptionV4RootView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel.loadingStatePublisher.value == false else { return }
        guard let selectedIdentifier = viewModel.cellViewModels[indexPath.row].identifier else { return }
        viewModel.handleProductSelection(identifier: selectedIdentifier)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = viewModel.cellViewModels[indexPath.row]
        return VxV4PaywallProductCell.hasSecondRow(for: model) ? 72 : 56
    }
}
#endif
