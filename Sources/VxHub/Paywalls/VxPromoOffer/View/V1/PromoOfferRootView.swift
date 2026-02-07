import UIKit
import Combine

final class PromoOfferRootView: VxNiblessView {
    private let viewModel: PromoOfferViewModel
    
    // MARK: - Properties
    private var scrollTimer: Timer?
    private let scrollSpeed: CGFloat = 1.0 // Points per frame
    private let buffer = 4 // max items visible at the same time
    private var totalElements = 0
    private var disposeBag = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var showCaseScrollView0: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    private lazy var showCaseScrollView1: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var titleLabel: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.PromoOffer.navigationTitle
        label.textColor = .white
        label.setFont(.custom("Roboto"), size: 20, weight: .bold)
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "special_offer_x_mark"), for: .normal)
        button.tintColor = .bx48486B
        return button
    }()
    
    private lazy var discountLabel: VxGradientLabel = {
        let label = VxGradientLabel(
            gradientColors: [
                UIColor(red: 154/255, green: 213/255, blue: 255/255, alpha: 1).cgColor, // #9AD5FF
                UIColor(red: 148/255, green: 166/255, blue: 255/255, alpha: 1).cgColor, // #94A6FF
                UIColor(red: 156/255, green: 199/255, blue: 255/255, alpha: 1).cgColor  // #9CC7FF
            ]
        )
        label.font =  UIFont(name: "Roboto-Bold", size: 50) ?? UIFont.systemFont(ofSize: 50, weight: .bold)
        let text = VxLocalizables.Subscription.PromoOffer.discountAmountDescription
        let key = "{{value_1}}"
        let percentage = viewModel.calculateDiscountPercentage
        label.text = text.replacingOccurrences(of: key, with: percentage)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.transform = CGAffineTransform(rotationAngle: -7.13 * .pi / 180)
        label.layer.shadowColor = UIColor(red: 113/255, green: 170/255, blue: 226/255, alpha: 0.5).cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowRadius = 16
        label.layer.shadowOpacity = 1.0
        label.layer.masksToBounds = false
        return label
    }()
    
    private lazy var descriptionLabel: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.PromoOffer.yearlyPlanDescription
        label.replaceValues([self.viewModel.calculateDiscountPercentage])
        label.textColor = .bxCFCEE9
        label.setFont(.custom("Roboto"), size: 14, weight: .regular)
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var oneTimeLabel: VxLabel = {
        let label = VxLabel() //TODO: ADD IMAGE ATT STRING TO VXLABEL
        
        let checkmarkAttachment = NSTextAttachment()
        checkmarkAttachment.image = UIImage(named: "checkIcon")?.withTintColor(.bx4BE162, renderingMode: .alwaysOriginal)
        checkmarkAttachment.bounds = CGRect(x: 0, y: -3, width: 16, height: 16)
        
        let checkmarkString = NSAttributedString(attachment: checkmarkAttachment)
        let textString = NSAttributedString(string: " " + VxLocalizables.Subscription.PromoOffer.onlyOnceLabel, attributes: [
            .font: UIFont(name: "Roboto-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.bx4BE162
        ])
        let attributedText = NSMutableAttributedString()
        attributedText.append(checkmarkString)
        attributedText.append(textString)
        label.attributedText = attributedText
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    
    private lazy var priceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var oldPriceLabel: VxLabel = {
        let label = VxLabel()
        label.textColor = .bx9494A8
        label.setFont(.custom("Roboto"), size: 24, weight: .semibold)
        label.textAlignment = .right
        label.attributedText = NSAttributedString(string: viewModel.productToCompare?.localizedPrice ?? "", attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var arrowLabel: VxLabel = {
        let label = VxLabel()
        label.text = ">"
        label.textColor = .white
        label.setFont(.custom("Roboto"), size: 24, weight: .semibold)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var newPriceLabel: VxLabel = {
        let label = VxLabel()
        label.text = viewModel.product?.localizedPrice
        label.textColor = .white
        label.setFont(.custom("Roboto"), size: 24, weight: .semibold)
        label.textAlignment = .left
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var claimButton: VxButton = {
        let button = VxButton(font: .rounded,
                             fontSize: 16,
                             weight: .semibold)
        button.configure(backgroundColor: .bx478AFF,
                         foregroundColor: .white,
                        cornerRadius: 16)
        button.setTitle(VxLocalizables.Subscription.PromoOffer.claimOfferButtonLabel, for: .normal)
        return button
    }()
    
    private lazy var mainActionToRestoreStackPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    //MARK: - Restore Buttons
    private lazy var termsButtonVerticalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var termsHorizontalButtonStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 3
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var restoreButton: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.restorePurchaseLabel
        label.setFont(.custom("Roboto"), size: 12, weight: .medium)
        label.numberOfLines = 1
        label.textColor = .bx455288
        return label
    }()
    
    private lazy var restoreTermsSeperator: VxLabel = {
        let label = VxLabel()
        label.text = "|"
        label.setFont(.custom("Roboto"), size: 12, weight: .medium)
        label.textColor = .bx455288
        return label
    }()
    
    private lazy var termsButton: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.termsOfUse
        label.setFont(.custom("Roboto"), size: 12, weight: .medium)
        label.numberOfLines = 1
        label.textColor = .bx455288
//    button.addTarget(self, action: #selector(privacyButtonTapped), for: .touchUpInside)
        return label
    }()
    
    private lazy var termsPrivacySeperator: VxLabel = {
        let label = VxLabel()
        label.text = "|"
        label.setFont(.custom("Roboto"), size: 12, weight: .medium)
        label.textColor = .bx455288
        return label
    }()
    
    private lazy var privacyButton: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.privacyPol
        label.setFont(.custom("Roboto"), size: 12, weight: .medium)
        label.numberOfLines = 1
        label.textColor = .bx455288
//    button.addTarget(self, action: #selector(privacyButtonTapped), for: .touchUpInside)
        return label
    }()
    
    private lazy var scrollContent0StackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var scrollContent1StackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
        
    // MARK: - Initialization
    init(viewModel: PromoOfferViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .bxNavyBlue
        setupHierarchy()
        setupConstraints()
        setupActions()
        setupShowcaseItems()
        startScrolling()
        subscribe()
    }
    
    private func setupHierarchy() {
        addSubview(mainStackView)
        
        // Header
        headerStackView.addArrangedSubview(UIView())  // Left spacer
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(closeButton)
        mainStackView.addArrangedSubview(headerStackView)
        
        // Add spacing
        mainStackView.addArrangedSubview(UIView.spacer(height: 32))
        
        // Discount
        mainStackView.addArrangedSubview(discountLabel)
        mainStackView.addArrangedSubview(UIView.spacer(height: 32))
        
        // Categories
//        mainStackView.addArrangedSubview(categoriesCollectionView)
        mainStackView.addArrangedSubview(showCaseScrollView0)
        mainStackView.addArrangedSubview(UIView.spacer(height: 16))
        mainStackView.addArrangedSubview(showCaseScrollView1)
        mainStackView.addArrangedSubview(UIView.spacer(height: 32))

        
        // Description
        mainStackView.addArrangedSubview(descriptionLabel)
        
        // Flexible space
        mainStackView.addArrangedSubview(UIView.flexibleSpacer())
        
        mainStackView.addArrangedSubview(oneTimeLabel)
        mainStackView.addArrangedSubview(UIView.spacer(height: 24))
        
        // Price
        priceStackView.addArrangedSubview(oldPriceLabel)
        priceStackView.addArrangedSubview(arrowLabel)
        priceStackView.addArrangedSubview(newPriceLabel)
        mainStackView.addArrangedSubview(priceStackView)
        
        mainStackView.addArrangedSubview(UIView.spacer(height: 24))
        
        // Claim button and footer
        mainStackView.addArrangedSubview(claimButton)
        mainStackView.addArrangedSubview(UIView.spacer(height: 24))
        
        termsHorizontalButtonStack.addArrangedSubview(restoreButton)
        termsHorizontalButtonStack.addArrangedSubview(restoreTermsSeperator)
        termsHorizontalButtonStack.addArrangedSubview(termsButton)
        termsHorizontalButtonStack.addArrangedSubview(termsPrivacySeperator)
        termsHorizontalButtonStack.addArrangedSubview(privacyButton)
        mainStackView.addArrangedSubview(termsButtonVerticalStack)
        termsButtonVerticalStack.addArrangedSubview(termsHorizontalButtonStack)

        showCaseScrollView0.addSubview(scrollContent0StackView)
        showCaseScrollView1.addSubview(scrollContent1StackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            mainStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            headerStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 48),
        
            claimButton.heightAnchor.constraint(equalToConstant: 48),
            claimButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 48),
            
            showCaseScrollView0.heightAnchor.constraint(equalToConstant: 70),
            showCaseScrollView1.heightAnchor.constraint(equalToConstant: 70),
            
            showCaseScrollView0.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            showCaseScrollView1.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            
            scrollContent0StackView.topAnchor.constraint(equalTo: showCaseScrollView0.topAnchor),
            scrollContent0StackView.leadingAnchor.constraint(equalTo: showCaseScrollView0.leadingAnchor, constant: 16),
            scrollContent0StackView.trailingAnchor.constraint(equalTo: showCaseScrollView0.trailingAnchor, constant: -16),
            scrollContent0StackView.bottomAnchor.constraint(equalTo: showCaseScrollView0.bottomAnchor),
            
            scrollContent1StackView.topAnchor.constraint(equalTo: showCaseScrollView1.topAnchor),
            scrollContent1StackView.leadingAnchor.constraint(equalTo: showCaseScrollView1.leadingAnchor, constant: 16),
            scrollContent1StackView.trailingAnchor.constraint(equalTo: showCaseScrollView1.trailingAnchor, constant: -16),
            scrollContent1StackView.bottomAnchor.constraint(equalTo: showCaseScrollView1.bottomAnchor),
            
            scrollContent0StackView.heightAnchor.constraint(equalTo: showCaseScrollView0.heightAnchor),
            scrollContent1StackView.heightAnchor.constraint(equalTo: showCaseScrollView1.heightAnchor),
        ])
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        claimButton.addTarget(self, action: #selector(claimButtonTapped), for: .touchUpInside)
        
        let restoreTap = UITapGestureRecognizer(target: self, action: #selector(restoreButtonTapped))
        restoreButton.isUserInteractionEnabled = true
        restoreButton.addGestureRecognizer(restoreTap)
        
        let termsTap = UITapGestureRecognizer(target: self, action: #selector(termsButtonTapped))
        termsButton.isUserInteractionEnabled = true
        termsButton.addGestureRecognizer(termsTap)
        
        let privacyTap = UITapGestureRecognizer(target: self, action: #selector(privacyButtonTapped))
        privacyButton.isUserInteractionEnabled = true
        privacyButton.addGestureRecognizer(privacyTap)
    }
    
    private func setupShowcaseItems() {
        let items = viewModel.categories
        let tripleItems = items + items + items
        
        tripleItems.forEach { category in
            let item0 = ShowcaseItemView()
            item0.configure(with: category)
            item0.translatesAutoresizingMaskIntoConstraints = false
            scrollContent0StackView.addArrangedSubview(item0)
        }
        
        
        tripleItems.forEach { category in
            let item1 = ShowcaseItemView()
            item1.configure(with: category)
            item1.translatesAutoresizingMaskIntoConstraints = false
            scrollContent1StackView.addArrangedSubview(item1)
        }
        
        layoutIfNeeded()
        
        let contentWidth0 = scrollContent0StackView.frame.width
        let contentWidth1 = scrollContent1StackView.frame.width
        
        showCaseScrollView0.contentSize = CGSize(width: contentWidth0, height: 70)
        showCaseScrollView1.contentSize = CGSize(width: contentWidth1, height: 70)
        
//        let screenWidth = UIScreen.main.bounds.width
        showCaseScrollView0.contentOffset.x = contentWidth0 / 3
        showCaseScrollView1.contentOffset.x = contentWidth1 / 3 * 2
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        viewModel.delegate?.promoOfferDidClose()
    }
    
    @objc private func claimButtonTapped() {
        viewModel.purchaseAction()
    }
    
    @objc private func restoreButtonTapped() {
        viewModel.restoreAction()
    }
    
    @objc private func termsButtonTapped() {
        VxHub.shared.showEula(isFullScreen: false,showCloseButton: false)
    }
    
    @objc private func privacyButtonTapped() {
        VxHub.shared.showPrivacy(isFullScreen: false,showCloseButton: false)
    }
    
    private func startScrolling() {
        scrollTimer?.invalidate()
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            self?.updateScroll()
        }
        if let timer = scrollTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    @objc private func updateScroll() {        
        let currentOffset0 = showCaseScrollView0.contentOffset.x
        let contentWidth0 = showCaseScrollView0.contentSize.width
        let oneThirdWidth0 = contentWidth0 / 3
        
        var newOffset0 = currentOffset0 + scrollSpeed
        if newOffset0 >= (oneThirdWidth0 * 2) {
            newOffset0 = oneThirdWidth0
        }
        showCaseScrollView0.setContentOffset(CGPoint(x: newOffset0, y: 0), animated: false)
        
        let currentOffset1 = showCaseScrollView1.contentOffset.x
        let contentWidth1 = showCaseScrollView1.contentSize.width
        let oneThirdWidth1 = contentWidth1 / 3
        
        var newOffset1 = currentOffset1 - scrollSpeed
        if newOffset1 <= oneThirdWidth1 {
            newOffset1 = oneThirdWidth1 * 2
        }
        showCaseScrollView1.setContentOffset(CGPoint(x: newOffset1, y: 0), animated: false)
    }
    
    private func subscribe() {
        viewModel.loadingStatePublisher
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] isLoading in
                self?.setLoadingState(isLoading)
            }
            .store(in: &disposeBag)
    }
    
    private func setLoadingState(_ isLoading: Bool) {
        if isLoading {
            self.claimButton.isLoading = true
            self.closeButton.alpha = 0.0
        }else{
            self.claimButton.isLoading = false
            self.closeButton.alpha = 1.0
        }
        claimButton.isEnabled = !isLoading
        closeButton.isEnabled = !isLoading
    }
    
}

// MARK: - GradientView
final class GradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    private var currentColors: [CGColor]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradient() {
        gradientLayer.startPoint = CGPoint(x: 1, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        gradientLayer.drawsAsynchronously = true
        gradientLayer.shouldRasterize = true
        gradientLayer.rasterizationScale = UIScreen.main.scale
        gradientLayer.actions = ["colors": NSNull()] // Disable implicit animations
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        CATransaction.commit()
    }
    
    func setGradient(colors: (UIColor, UIColor)) {
        let newColors = [colors.0.cgColor, colors.1.cgColor]
        if currentColors != newColors {
            currentColors = newColors
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            gradientLayer.colors = newColors
            CATransaction.commit()
        }
    }
}

// MARK: - CustomFlowLayout
final class CustomFlowLayout: UICollectionViewFlowLayout {
    var numberOfLines: Int = 2
    var lineSpacing: CGFloat = 16
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        var modifiedAttributes = [UICollectionViewLayoutAttributes]()
        let halfCount = attributes.count / 2
        
        for (index, attribute) in attributes.enumerated() {
            let copiedAttribute = attribute.copy() as! UICollectionViewLayoutAttributes
            
            if index >= halfCount {
                copiedAttribute.frame.origin.y = itemSize.height + lineSpacing
            }
            
            modifiedAttributes.append(copiedAttribute)
        }
        
        return modifiedAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

internal extension UIColor {
    
    @nonobjc class var bx478AFF: UIColor {
        return UIColor(red: 71/255.0,
                       green: 138 / 255.0,
                       blue: 255 / 255.0,
                       alpha: 1.0)
    }
                       
    @nonobjc class var bx455288: UIColor {
        return UIColor(red: 69 / 255.0,
                       green: 82 / 255.0,
                       blue: 136 / 255.0,
                       alpha: 1.0)
    }
    
    @objc class var bxCFCEE9: UIColor {
        return UIColor(red: 207 / 255.0,
                       green: 206 / 255.0,
                       blue: 233 / 255.0,
                       alpha: 1.0)
    }
    
    @objc class var bx4BE162: UIColor {
        return UIColor(red: 75 / 255.0,
                       green: 225 / 255.0,
                       blue: 98 / 255.0,
                       alpha: 1.0)
    }
        
    @objc class var bx9494A8: UIColor {
        return UIColor(red: 148 / 255.0,
                       green: 148 / 255.0,
                       blue: 168 / 255.0,
                       alpha: 1.0)
    }
    
    @objc class var bx48486B: UIColor {
        return UIColor(red: 72 / 255.0,
                       green: 72 / 255.0,
                       blue: 107 / 255.0,
                       alpha: 1.0)
    }
    
    @nonobjc class var bxNavyBlue: UIColor {
        return UIColor(red: 20 / 255.0,
                       green: 33 / 255.0,
                       blue: 61 / 255.0,
                       alpha: 1.0)
    }
}

