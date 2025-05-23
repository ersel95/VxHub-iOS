import UIKit
import Combine
import AVFoundation

final class PromoOfferV2RootView: VxNiblessView {
    private let viewModel: PromoOfferViewModel
    
    // MARK: - Properties
    private var disposeBag = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var topDiscountHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.transform = CGAffineTransform(rotationAngle: -7.13 * .pi / 180)
        return stack
    }()
    
    private lazy var topDiscountVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = -12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var topDiscountTitleLabel: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.PromoOffer.discountTitle
        label.setFont(.custom("Manrope"), size: 16, weight: .semibold)
        label.textColor = .white
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var topDiscountDescriptionLabel: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.PromoOffer.discountAmountDescription
        label.setFont(.custom("Manrope"), size: 56, weight: .bold)
        label.replaceValues([viewModel.calculateDiscountPercentage])
        label.textColor = .white
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.layer.shadowColor = UIColor.white.cgColor
        label.layer.shadowRadius = 4.0
        label.layer.shadowOpacity = 0.9
        label.layer.shadowOffset = CGSize.zero
        label.layer.masksToBounds = false
        return label
    }()

    private lazy var videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var videoContentPlaceholder: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.PromoOffer.navigationTitle
        label.textColor = .white
        label.setFont(.custom("Manrope"), size: 20, weight: .bold)
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .bx9494A8
        button.translatesAutoresizingMaskIntoConstraints = false
        
        if let image = button.imageView {
            image.contentMode = .scaleAspectFit
            image.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                image.widthAnchor.constraint(equalToConstant: 12),
                image.heightAnchor.constraint(equalToConstant: 12),
                image.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                image.centerYAnchor.constraint(equalTo: button.centerYAnchor)
            ])
        }
        return button
    }()
    
    private lazy var descriptionLabel: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.PromoOffer.yearlyPlanDescription
        label.replaceValues([self.viewModel.calculateDiscountPercentage])
        label.textColor = .white
        label.setFont(.custom("Manrope"), size: 16, weight: .medium)
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var oneTimeLabel: VxLabel = {
        let label = VxLabel() //TODO: ADD IMAGE ATT STRING TO VXLABEL
        
        let checkmarkAttachment = NSTextAttachment()
        checkmarkAttachment.image = UIImage(named: "gren_tick_icon", in: .module, compatibleWith: nil)?.withTintColor(.bx4BE162, renderingMode: .alwaysOriginal)
        checkmarkAttachment.bounds = CGRect(x: 0, y: -3, width: 16, height: 16)
        
        let checkmarkString = NSAttributedString(attachment: checkmarkAttachment)
        let textString = NSAttributedString(string: " " + VxLocalizables.Subscription.PromoOffer.onlyOnceLabel, attributes: [
            .font: UIFont(name: "Manrope-Semibold", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .semibold),
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
        label.setFont(.custom("Manrope"), size: 24, weight: .semibold)
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
        label.setFont(.custom("Manrope"), size: 24, weight: .semibold)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var newPriceLabel: VxLabel = {
        let label = VxLabel()
        label.text = viewModel.product?.localizedPrice
        label.textColor = .white
        label.setFont(.custom("Manrope"), size: 24, weight: .semibold)
        label.textAlignment = .left
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var claimButton: VxLoadingButton = {
        let button = VxLoadingButton(type: .system)
        button.titleLabel?.font = .custom(VxFont.custom("Manrope"), size: 16, weight: .semibold)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 190/255, green: 13/255, blue: 167/255, alpha: 1.0).cgColor,
            UIColor(red: 240/255, green: 48/255, blue: 62/255, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        button.setTitle(VxLocalizables.Subscription.PromoOffer.claimOfferButtonLabel, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        
        self.buttonGradientLayer = gradientLayer
        return button
    }()
    
    private var buttonGradientLayer: CAGradientLayer?
    
    private lazy var secureInfoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 0
        return stack
    }()
        
    private lazy var secureInfoVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var secureInfoImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "secure_restore_icon", in: .module, compatibleWith: nil)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var secureInfoImageVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    private lazy var secureInfoLabel: VxLabel = {
        let label = VxLabel()
        label.textColor = .white
        label.setFont(.custom("Manrope"), size: 12, weight: .regular)
        label.textAlignment = .center
        label.text = VxLocalizables.Subscription.PromoOffer.secureInfoLabel
        return label
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
        label.setFont(.custom("Manrope"), size: 12, weight: .medium)
        label.numberOfLines = 1
        label.textColor = UIColor.colorConverter("535353")
        return label
    }()
    
    private lazy var restoreTermsSeperator: VxLabel = {
        let label = VxLabel()
        label.text = "|"
        label.setFont(.custom("Manrope"), size: 12, weight: .medium)
        label.textColor = UIColor.colorConverter("535353")
        return label
    }()
    
    private lazy var termsButton: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.termsOfUse
        label.setFont(.custom("Manrope"), size: 12, weight: .medium)
        label.numberOfLines = 1
        label.textColor = UIColor.colorConverter("535353")
        return label
    }()
    
    private lazy var termsPrivacySeperator: VxLabel = {
        let label = VxLabel()
        label.text = "|"
        label.setFont(.custom("Manrope"), size: 12, weight: .medium)
        label.textColor = UIColor.colorConverter("535353")
        return label
    }()
    
    private lazy var privacyButton: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.privacyPol
        label.setFont(.custom("Manrope"), size: 12, weight: .medium)
        label.numberOfLines = 1
        label.textColor = UIColor.colorConverter("535353")
        return label
    }()
    
    // MARK: - Additional Properties
    private lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = .resize
        layer.player = player
//        layer.transform = CATransform3DMakeScale(5.0, 5.0, 1.0)
        return layer
    }()
    
    private lazy var player: AVQueuePlayer = {
        let player = AVQueuePlayer()
        player.isMuted = true
        return player
    }()

    private var playerLooper: AVPlayerLooper?
    
    // MARK: - Initialization
    init(viewModel: PromoOfferViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupVideo()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .black
        setupHierarchy()
        setupConstraints()
        setupActions()
        subscribe()
    }
    
    private func setupHierarchy() {
        addSubview(mainStackView)
        addSubview(closeButton)
        addSubview(topDiscountTitleLabel)
        // Description
        mainStackView.addArrangedSubview(UIView.spacer(height: 40))
        mainStackView.addArrangedSubview(self.topDiscountHorizontalStack)
        topDiscountHorizontalStack.addArrangedSubview(UIView.spacer(width: 12))
        topDiscountHorizontalStack.addArrangedSubview(self.topDiscountVerticalStack)
        topDiscountHorizontalStack.addArrangedSubview(UIView.spacer(width: 12))
        topDiscountVerticalStack.addArrangedSubview(topDiscountTitleLabel)
        topDiscountVerticalStack.addArrangedSubview(topDiscountDescriptionLabel)
        mainStackView.addArrangedSubview(self.videoContainerView)
        
        mainStackView.addArrangedSubview(UIView.spacer(height: 4))
        mainStackView.addArrangedSubview(descriptionLabel)
        mainStackView.addArrangedSubview(UIView.spacer(height: 8))
        // Flexible space
        
        mainStackView.addArrangedSubview(oneTimeLabel)
        mainStackView.addArrangedSubview(UIView.spacer(height: 16))
        
        // Price
        priceStackView.addArrangedSubview(oldPriceLabel)
        priceStackView.addArrangedSubview(arrowLabel)
        priceStackView.addArrangedSubview(newPriceLabel)
        mainStackView.addArrangedSubview(priceStackView)
        
        mainStackView.addArrangedSubview(UIView.spacer(height: 20))
        
        // Claim button and footer
        mainStackView.addArrangedSubview(claimButton)
        mainStackView.addArrangedSubview(UIView.spacer(height: 12))
        mainStackView.addArrangedSubview(secureInfoStack)
        
//        secureInfoVerticalStack.addArrangedSubview(secureInfoStack)
        secureInfoStack.addArrangedSubview(UIView.spacer(width: 8))
        secureInfoStack.addArrangedSubview(secureInfoImageVerticalStack)
        secureInfoImageVerticalStack.addArrangedSubview(secureInfoImageView)
        secureInfoImageVerticalStack.addArrangedSubview(UIView.flexibleSpacer())
        secureInfoStack.addArrangedSubview(UIView.spacer(width: 8))
        secureInfoStack.addArrangedSubview(secureInfoLabel)
        secureInfoStack.addArrangedSubview(UIView.spacer(width: 8))
        
        mainStackView.addArrangedSubview(UIView.spacer(height: 16))
        
        termsHorizontalButtonStack.addArrangedSubview(restoreButton)
        termsHorizontalButtonStack.addArrangedSubview(restoreTermsSeperator)
        termsHorizontalButtonStack.addArrangedSubview(termsButton)
        termsHorizontalButtonStack.addArrangedSubview(termsPrivacySeperator)
        termsHorizontalButtonStack.addArrangedSubview(privacyButton)
        mainStackView.addArrangedSubview(termsButtonVerticalStack)
        termsButtonVerticalStack.addArrangedSubview(termsHorizontalButtonStack)
        
        // Add a flexible spacer after the video container
//        mainStackView.addArrangedSubview(UIView())
        
        videoContainerView.layer.addSublayer(playerLayer)
        topDiscountDescriptionLabel.setContentHuggingPriority(.required, for: .vertical)
        self.secureInfoLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private func setupConstraints() {
        secureInfoImageVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        secureInfoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            mainStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            secureInfoImageView.heightAnchor.constraint(equalToConstant: 16),
            secureInfoImageVerticalStack.widthAnchor.constraint(equalToConstant: 16),
            
            topDiscountVerticalStack.heightAnchor.constraint(equalToConstant: 100),
            claimButton.heightAnchor.constraint(equalToConstant: 48),
            claimButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 48),
            
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            videoContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            videoContainerView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            topDiscountHorizontalStack.heightAnchor.constraint(equalToConstant: 85)
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
            claimButton.isLoading = true
            self.closeButton.isEnabled = false
            self.closeButton.isHidden = true
        }else{
            claimButton.isLoading = false
            self.closeButton.isEnabled = true
            self.closeButton.isHidden = false
        }
        claimButton.isEnabled = !isLoading
        closeButton.isEnabled = !isLoading
    }
    
    private func setupVideo() {
        videoContainerView.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        DispatchQueue.main.async { [weak self] in
            self?.player.pause()
        }
    }
    
    @objc private func appWillEnterForeground() {
        DispatchQueue.main.async { [weak self] in
            self?.player.play()
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.buttonGradientLayer?.frame = self.claimButton.bounds
            playerLayer.frame = videoContainerView.bounds

        }
    }
    
    func setVideo(bundleName: String) {
        guard let videoURL = Bundle.main.url(forResource: bundleName, withExtension: "mp4") else {
            VxLogger.shared.error("Video file not found: \(bundleName)")
            return
        }
        
        player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
        
        if let asset = player.currentItem?.asset {
            let playerItem = AVPlayerItem(asset: asset)
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        }
        
        player.play()
    }
}
