#if canImport(UIKit)
import UIKit
import Combine

final public class VxStoreV1RootView: VxNiblessView {

    private let viewModel: VxStoreViewModel
    private let config: VxStoreV1Configuration

    private var dataSource: UICollectionViewDiffableDataSource<VxStoreDataSourceSection, VxStoreDataSourceModel>?
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
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: iconConfig)?
            .withTintColor(config.closeButtonColor, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = config.isLightMode ? UIColor(white: 0.9, alpha: 1.0) : UIColor(white: 0.2, alpha: 1.0)
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc private func closeButtonTapped() {
        guard viewModel.loadingStatePublisher.value == false else { return }
        viewModel.dismiss()
    }

    // MARK: - Hero Image
    private lazy var heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    // MARK: - Balance
    private lazy var balanceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        return stack
    }()

    private lazy var balanceIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var balanceTextLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        return label
    }()

    private lazy var balanceValueLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Headline
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

    // MARK: - Collection View
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeCompositionalLayout())
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false
        return cv
    }()

    // MARK: - CTA Button
    private lazy var ctaButton: VxLoadingButton = {
        let button = VxLoadingButton(type: .system)
        button.titleLabel?.font = .custom(config.font, size: 17, weight: .bold)
        button.setTitleColor(config.ctaButtonTextColor, for: .normal)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(ctaButtonTapped), for: .touchUpInside)
        return button
    }()

    private var ctaGradientLayer: CAGradientLayer?

    @objc private func ctaButtonTapped() {
        viewModel.purchaseAction()
    }

    // MARK: - Dummy Mode Banner
    private lazy var dummyBannerView: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.4).cgColor

        let icon = UIImageView()
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        icon.image = UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: iconConfig)
        icon.tintColor = .systemOrange
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "DEBUG MODE — Showing dummy products"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(icon)
        container.addSubview(label)
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.heightAnchor.constraint(equalToConstant: 32)
        ])
        return container
    }()

    // MARK: - Collection View Height
    private var collectionViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Init
    public init(frame: CGRect = .zero, viewModel: VxStoreViewModel, configuration: VxStoreV1Configuration) {
        self.viewModel = viewModel
        self.config = configuration
        super.init(frame: frame)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.setupUI()
            self.constructHierarchy()
            self.setupCollectionDataSource()
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
        self.backgroundColor = config.backgroundColor
        let textColor = config.textColor
        let secondaryColor = config.isLightMode ? UIColor(white: 0.45, alpha: 1.0) : UIColor(white: 0.55, alpha: 1.0)

        // Hero image
        if let heroName = config.heroImageName, !heroName.isEmpty {
            heroImageView.image = UIImage(named: heroName)
            heroImageView.isHidden = (heroImageView.image == nil)
        } else {
            heroImageView.isHidden = true
        }

        // Balance
        if config.showBalance {
            if let iconName = config.balanceIcon {
                let iconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
                balanceIconView.image = UIImage(systemName: iconName, withConfiguration: iconConfig)
                balanceIconView.tintColor = .systemYellow
            }
            balanceTextLabel.setFont(config.font, size: 15, weight: .medium)
            balanceTextLabel.textColor = secondaryColor
            balanceTextLabel.text = config.balanceLabel

            balanceValueLabel.setFont(config.font, size: 15, weight: .bold)
            balanceValueLabel.textColor = textColor
            balanceValueLabel.text = "\(VxHub.shared.balance)"
            balanceStack.isHidden = false
        } else {
            balanceStack.isHidden = true
        }

        // Headline
        headlineLabel.setFont(config.font, size: 26, weight: .bold)
        headlineLabel.textColor = textColor
        headlineLabel.text = config.headlineText

        subtitleLabel.setFont(config.font, size: 16, weight: .regular)
        subtitleLabel.textColor = secondaryColor
        subtitleLabel.text = config.subtitleText

        // CTA
        if config.purchaseMode == .selectAndBuy {
            setupCTAButtonColors()
            ctaButton.setTitle(config.ctaText ?? "Purchase", for: .normal)
            ctaButton.isHidden = false
        } else {
            ctaButton.isHidden = true
        }
    }

    private func setupCTAButtonColors() {
        if let endColor = config.ctaGradientEndColor {
            let gradient = CAGradientLayer()
            gradient.colors = [config.ctaButtonColor.cgColor, endColor.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            ctaButton.layer.insertSublayer(gradient, at: 0)
            self.ctaGradientLayer = gradient
        } else {
            ctaButton.backgroundColor = config.ctaButtonColor
        }
    }

    // MARK: - Layout
    private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let columns = CGFloat(config.columnsCount)
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / columns),
            heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Hierarchy
    private func constructHierarchy() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        balanceIconView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)
        addSubview(closeButton)
        scrollView.addSubview(contentStackView)

        collectionView.delegate = self
        collectionView.registerCell(cellType: VxStoreV1ProductCell.self)

        // Balance
        let balanceCenterStack = centeredContainer(balanceStack)
        balanceStack.addArrangedSubview(balanceIconView)
        balanceStack.addArrangedSubview(balanceTextLabel)
        balanceStack.addArrangedSubview(balanceValueLabel)

        // Hero
        let heroContainer = centeredContainer(heroImageView)

        // Headline
        let headlineContainer = paddedHStack(headlineLabel, horizontalPadding: 24)
        let subtitleContainer = paddedHStack(subtitleLabel, horizontalPadding: 24)

        // Collection
        let collectionContainer = paddedHStack(collectionView, horizontalPadding: 16)

        // CTA
        let ctaContainer = paddedHStack(ctaButton, horizontalPadding: 24)

        // Build stack
        contentStackView.addArrangedSubview(UIView.spacer(height: 48))

        if viewModel.isDummyMode {
            let dummyContainer = paddedHStack(dummyBannerView, horizontalPadding: 24)
            contentStackView.addArrangedSubview(dummyContainer)
            contentStackView.addArrangedSubview(UIView.spacer(height: 12))
        }

        if !heroImageView.isHidden {
            contentStackView.addArrangedSubview(heroContainer)
            contentStackView.addArrangedSubview(UIView.spacer(height: 16))
        }

        if config.showBalance {
            contentStackView.addArrangedSubview(balanceCenterStack)
            contentStackView.addArrangedSubview(UIView.spacer(height: 12))
        }

        if config.headlineText != nil {
            contentStackView.addArrangedSubview(headlineContainer)
            contentStackView.addArrangedSubview(UIView.spacer(height: 8))
        }
        if config.subtitleText != nil {
            contentStackView.addArrangedSubview(subtitleContainer)
            contentStackView.addArrangedSubview(UIView.spacer(height: 16))
        }

        contentStackView.addArrangedSubview(collectionContainer)

        if config.purchaseMode == .selectAndBuy {
            contentStackView.addArrangedSubview(UIView.spacer(height: 24))
            contentStackView.addArrangedSubview(ctaContainer)
        }

        contentStackView.addArrangedSubview(UIView.spacer(height: 24))

        // Calculate collection height
        let productCount = viewModel.cellViewModels.count
        let rows = Int(ceil(Double(productCount) / Double(config.columnsCount)))
        let estimatedRowHeight: CGFloat = 210
        let collectionHeight = CGFloat(rows) * estimatedRowHeight

        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: collectionHeight)
        collectionViewHeightConstraint?.isActive = true

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

            ctaButton.heightAnchor.constraint(equalToConstant: 54),

            balanceIconView.widthAnchor.constraint(equalToConstant: 24),
            balanceIconView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    // MARK: - Bindables
    private func setupBindables() {
        viewModel.selectedProductPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }
            .store(in: &disposeBag)

        viewModel.loadingStatePublisher
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] isLoading in
                self?.setLoadingState(isLoading)
            }
            .store(in: &disposeBag)

        viewModel.purchasedProductPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.balanceValueLabel.text = "\(VxHub.shared.balance)"
            }
            .store(in: &disposeBag)
    }

    private func setLoadingState(_ isLoading: Bool) {
        if config.purchaseMode == .selectAndBuy {
            ctaButton.isLoading = isLoading
        }
        collectionView.isUserInteractionEnabled = !isLoading
        if config.isCloseButtonEnabled {
            closeButton.isEnabled = !isLoading
            closeButton.isHidden = isLoading
        }
    }

    // MARK: - Close Button Delay
    private func setupCloseButtonDelay() {
        if !config.isCloseButtonEnabled {
            closeButton.isHidden = true
            return
        }
        if config.closeButtonDelay > 0 {
            closeButton.isHidden = true
            closeButtonTimer = Timer.scheduledTimer(withTimeInterval: config.closeButtonDelay, repeats: false) { [weak self] _ in
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

    // MARK: - Collection DataSource
    private func setupCollectionDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, model in
                guard let self else { return UICollectionViewCell() }
                let cell = collectionView.dequeueReusableCell(with: VxStoreV1ProductCell.self, for: indexPath)
                cell.configure(with: model, configuration: self.config) { [weak self] identifier in
                    self?.viewModel.purchaseAction(identifier: identifier)
                }
                return cell
            })
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<VxStoreDataSourceSection, VxStoreDataSourceModel>()
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
}

// MARK: - UICollectionViewDelegate
extension VxStoreV1RootView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard viewModel.loadingStatePublisher.value == false else { return }
        guard config.purchaseMode == .selectAndBuy else { return }
        let identifier = viewModel.cellViewModels[indexPath.item].identifier
        viewModel.handleProductSelection(identifier: identifier)
    }
}
#endif
