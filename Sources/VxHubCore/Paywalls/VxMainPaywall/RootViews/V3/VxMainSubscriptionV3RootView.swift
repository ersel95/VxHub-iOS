#if canImport(UIKit)
import UIKit
import Combine

final public class VxMainSubscriptionV3RootView: VxNiblessView {

    private let viewModel: VxMainSubscriptionViewModel
    private let v3Config: VxMainPaywallV3Configuration

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
            .withTintColor(v3Config.closeButtonColor, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = v3Config.isLightMode ? UIColor(white: 0.9, alpha: 1.0) : UIColor(white: 0.2, alpha: 1.0)
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

    // MARK: - CTA Button
    private lazy var ctaButton: VxLoadingButton = {
        let button = VxLoadingButton(type: .system)
        button.titleLabel?.font = .custom(v3Config.font, size: 17, weight: .bold)
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
        VxHub.shared.showEula(isFullScreen: false)
    }

    @objc private func privacyButtonTapped() {
        VxHub.shared.showPrivacy(isFullScreen: false)
    }

    @objc private func redeemButtonTapped() {
        viewModel.onReedemCodaButtonTapped?()
    }

    // MARK: - Init
    public init(frame: CGRect = .zero, viewModel: VxMainSubscriptionViewModel, v3Configuration: VxMainPaywallV3Configuration) {
        self.viewModel = viewModel
        self.v3Config = v3Configuration
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
        self.backgroundColor = v3Config.backgroundColor

        let textColor = v3Config.textColor
        let secondaryColor = v3Config.isLightMode ? UIColor(white: 0.45, alpha: 1.0) : UIColor(white: 0.55, alpha: 1.0)
        let footerColor = v3Config.isLightMode ? UIColor(white: 0.45, alpha: 1.0) : UIColor(white: 0.4, alpha: 1.0)

        // Rating section
        if let ratingValue = v3Config.ratingValue {
            setupStars(rating: Double(ratingValue) ?? 4.5)
            ratingValueLabel.setFont(v3Config.font, size: 15, weight: .bold)
            ratingValueLabel.textColor = textColor
            ratingValueLabel.text = ratingValue

            ratingCountLabel.setFont(v3Config.font, size: 14, weight: .regular)
            ratingCountLabel.textColor = secondaryColor
            if let count = v3Config.ratingCount {
                ratingCountLabel.text = "(\(count))"
            }
            ratingContainerStack.isHidden = false
        } else {
            ratingContainerStack.isHidden = true
        }

        // Hero image
        if let heroName = v3Config.heroImageName, !heroName.isEmpty {
            heroImageView.image = UIImage(named: heroName)
            heroImageView.isHidden = (heroImageView.image == nil)
        } else {
            heroImageView.isHidden = true
        }

        // Headline
        headlineLabel.setFont(v3Config.font, size: 26, weight: .bold)
        headlineLabel.textColor = textColor
        headlineLabel.text = v3Config.headlineText ?? fallback("Subscription_V3_HeadlineLabel", default: "Unlock Full Access")

        // Subtitle
        subtitleLabel.setFont(v3Config.font, size: 16, weight: .regular)
        subtitleLabel.textColor = secondaryColor
        subtitleLabel.text = v3Config.subtitleText ?? fallback("Subscription_V3_SubtitleLabel", default: "Start your free trial today")

        // Feature items — use SF Symbols directly
        let checkColor = v3Config.ctaButtonColor
        for item in v3Config.featureItems {
            let featureRow = makeFeatureRow(icon: item.icon, text: item.text, textColor: textColor, iconColor: checkColor)
            featureStackView.addArrangedSubview(featureRow)
        }

        // CTA button
        setupCTAButtonColors()

        // Trust line
        trustLockIcon.tintColor = secondaryColor
        trustLabel.setFont(v3Config.font, size: 13, weight: .medium)
        trustLabel.textColor = secondaryColor
        trustLabel.text = v3Config.trustText ?? fallback("Subscription_V3_TrustLineLabel", default: "No payment now · Cancel anytime")

        // Footer buttons
        [restoreButton, termsButton, privacyButton, redeemButton].forEach { label in
            label.setFont(v3Config.font, size: 12, weight: .medium)
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
        // Try SF Symbol first, fallback to named image
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
        label.setFont(v3Config.font, size: 15, weight: .medium)
        label.textColor = textColor
        label.numberOfLines = 0

        row.addArrangedSubview(imageView)
        row.addArrangedSubview(label)
        return row
    }

    private func setupCTAButtonColors() {
        if let endColor = v3Config.ctaGradientEndColor {
            let gradient = CAGradientLayer()
            gradient.colors = [v3Config.ctaButtonColor.cgColor, endColor.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            ctaButton.layer.insertSublayer(gradient, at: 0)
            self.ctaGradientLayer = gradient
        } else {
            ctaButton.backgroundColor = v3Config.ctaButtonColor
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
        productsTableView.rowHeight = 84
        productsTableView.registerCell(cellType: VxV3PaywallProductCell.self)

        // Rating section (centered)
        let ratingCenterStack = centeredHStack(ratingContainerStack)
        ratingContainerStack.addArrangedSubview(ratingStarsStack)
        ratingContainerStack.addArrangedSubview(ratingValueLabel)
        ratingContainerStack.addArrangedSubview(ratingCountLabel)

        // Hero image
        let heroContainer = centeredHStack(heroImageView)

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
        let trustCenterStack = centeredHStack(trustLineStack)
        trustLineStack.addArrangedSubview(trustLockIcon)
        trustLineStack.addArrangedSubview(trustLabel)

        // Footer (centered)
        let footerCenterStack = centeredHStack(footerStack)
        footerStack.addArrangedSubview(restoreButton)
        footerStack.addArrangedSubview(separatorLabel())
        footerStack.addArrangedSubview(termsButton)
        footerStack.addArrangedSubview(separatorLabel())
        footerStack.addArrangedSubview(privacyButton)
        footerStack.addArrangedSubview(separatorLabel())
        footerStack.addArrangedSubview(redeemButton)

        // Build content stack — close button area at top
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

        // Calculate table height based on product count
        let productCount = CGFloat(viewModel.cellViewModels.count)
        let tableHeight = productCount * 84

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

            productsTableView.heightAnchor.constraint(equalToConstant: tableHeight),

            ctaButton.heightAnchor.constraint(equalToConstant: 54),

            trustLockIcon.widthAnchor.constraint(equalToConstant: 14),
            trustLockIcon.heightAnchor.constraint(equalToConstant: 14)
        ])

        restoreButton.setContentHuggingPriority(.required, for: .horizontal)
        termsButton.setContentHuggingPriority(.required, for: .horizontal)
        privacyButton.setContentHuggingPriority(.required, for: .horizontal)
        redeemButton.setContentHuggingPriority(.required, for: .horizontal)
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

    private func updateCTAText(for selectedPackage: VxMainSubscriptionDataSourceModel?) {
        if let pkg = selectedPackage,
           let freeTrialUnit = pkg.freeTrialUnit, freeTrialUnit > 0,
           pkg.eligibleForFreeTrialOrDiscount == true,
           let trialPeriod = pkg.freeTrialPeriod {
            let trialString = trialPeriod.freeTrialString(value: freeTrialUnit)
            // Apple-compliant: "Start Free Trial — {duration}" clearly shows action + duration
            let localizedCTA = fallback("Subscription_V3_TryFreeButtonLabel", default: "Try Free for {xxxTrialDuration}")
            let ctaText = localizedCTA.replacingOccurrences(of: "{xxxTrialDuration}", with: trialString)
            ctaButton.setTitle(ctaText, for: .normal)
        } else {
            ctaButton.setTitle(fallback("Subscription_SubscribeButtonLabel", default: "Subscribe"), for: .normal)
        }
    }

    private func setLoadingState(_ isLoading: Bool) {
        ctaButton.isLoading = isLoading
        if v3Config.isCloseButtonEnabled {
            closeButton.isEnabled = !isLoading
            closeButton.isHidden = isLoading
        }
    }

    // MARK: - Close Button Delay
    private func setupCloseButtonDelay() {
        if !v3Config.isCloseButtonEnabled {
            closeButton.isHidden = true
            return
        }
        if v3Config.closeButtonDelay > 0 {
            closeButton.isHidden = true
            closeButtonTimer = Timer.scheduledTimer(withTimeInterval: v3Config.closeButtonDelay, repeats: false) { [weak self] _ in
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
                let cell = tableView.dequeueReusableCell(with: VxV3PaywallProductCell.self, for: indexPath)
                cell.selectionStyle = .none
                cell.configure(with: model, accentColor: self.v3Config.ctaButtonColor)
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

    /// Tries localize(), falls back to hardcoded English if the key is returned as-is
    private func fallback(_ key: String, default defaultValue: String) -> String {
        let localized = key.localize()
        // If localize() returns the key itself, use the hardcoded fallback
        if localized == key {
            return defaultValue
        }
        return localized
    }

    private func centeredHStack(_ view: UIView) -> UIStackView {
        let outer = UIStackView()
        outer.axis = .horizontal
        outer.alignment = .center
        outer.distribution = .fill
        outer.addArrangedSubview(UIView.flexibleSpacer())
        outer.addArrangedSubview(view)
        outer.addArrangedSubview(UIView.flexibleSpacer())
        return outer
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
        label.setFont(v3Config.font, size: 12, weight: .medium)
        label.textColor = v3Config.isLightMode ? UIColor(white: 0.45, alpha: 1.0) : UIColor(white: 0.4, alpha: 1.0)
        return label
    }
}

// MARK: - UITableViewDelegate
extension VxMainSubscriptionV3RootView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel.loadingStatePublisher.value == false else { return }
        guard let selectedIdentifier = viewModel.cellViewModels[indexPath.row].identifier else { return }
        viewModel.handleProductSelection(identifier: selectedIdentifier)
    }
}
#endif
