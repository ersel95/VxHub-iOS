//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import UIKit
import Combine
import AVFoundation

final public class VxMainSubscriptionV2RootView: VxNiblessView {
    
    private let viewModel: VxMainSubscriptionViewModel
    
    private var dataSource: DataSource?
    typealias DataSource = UITableViewDiffableDataSource<VxMainSubscriptionDataSourceSection, VxMainSubscriptionDataSourceModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<VxMainSubscriptionDataSourceSection, VxMainSubscriptionDataSourceModel>
    let helper = VxLayoutHelper()
    
    private var disposeBag = Set<AnyCancellable>()
    
    //MARK: - Colors
    let cancelAnytimeForegroundColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
    
    //MARK: - Base Components
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        if let backgroundImage = viewModel.configuration.backgroundImageName {
            imageView.image = UIImage(named:backgroundImage)
        }
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private lazy var mainVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        let image = UIImage(systemName: "xmark", withConfiguration: config)?.withTintColor(viewModel.configuration.closeButtonColor, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func closeButtonTapped() {
        guard self.viewModel.loadingStatePublisher.value == false else { return }
        self.viewModel.dismiss()
    }
    
    //MARK: - Base Components End
    private lazy var topSectionVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        return stackView
    }()
    
    
    //MARK: - Description Label Section
    private lazy var descrptionTopTitle: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.V2.unlockPremiumLabel
        label.textAlignment = .center
        label.setFont(viewModel.configuration.font, size: 25, weight: .bold)
        label.textColor = viewModel.configuration.textColor
        return label
    }()
    private lazy var descriptionLabelVerticalContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var descriptionLabelHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var descriptionItemViews: [VxPaywallDescriptionItem] = {
        let items = [VxPaywallDescriptionItem]()
        return items
    }()
    
    private lazy var descriptionItemsSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    //MARK: - Description Label Section End
    
    
    //MARK: - ProductsTable
    private lazy var productsTableViewHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var productsTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        return table
    }()
    //MARK: - ProductsTable End
    
    private lazy var productsTableToBottomStackPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
        
    private lazy var recurringCoinInfoVerticalStack = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    private lazy var recurringCoinInfoHorizontalStack = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    private lazy var recurringCoinInfoLabel: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.V2.recurringCoinDescriptionLabel
        if viewModel.configuration.paywallType == VxMainPaywallTypes.v1.rawValue {
            label.setFont(viewModel.configuration.font, size: 12, weight: .medium)
        }else{
            label.setFont(viewModel.configuration.font, size: 8, weight: .medium)
        }
        label.textColor = UIColor.colorConverter("B4B4B4")
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - BottomButtonStack
    private lazy var bottomButtonStackHorizontalStack = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.distribution = .fill
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var bottomButtonStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var mainActionButton: VxLoadingButton = {
        let button = VxLoadingButton(type: .system)
        button.titleLabel?.font = .custom(viewModel.configuration.font, size: 16, weight: .semibold)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 190/255, green: 13/255, blue: 167/255, alpha: 1.0).cgColor,
            UIColor(red: 240/255, green: 48/255, blue: 62/255, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        button.setTitle(VxLocalizables.Subscription.subscribeButtonLabel, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(mainActionButtonTapped), for: .touchUpInside)
        
        self.buttonGradientLayer = gradientLayer
        return button
    }()
    
    private var buttonGradientLayer: CAGradientLayer?
    
    @objc private func mainActionButtonTapped() {
        self.viewModel.purchaseAction()
    }
    
    private func setLoadingState(_ isLoading: Bool) {
        mainActionButton.isLoading = isLoading
        if self.viewModel.configuration.isCloseButtonEnabled {
            closeButton.isEnabled = !isLoading
            closeButton.isHidden = isLoading
        }else{
            closeButton.isEnabled = false
            closeButton.isHidden = true
        }
    }
    
    private lazy var mainActionButtonSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var cancelAnytimeVerticalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var cancelAnytimeHorizontalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var cancelAnytimeLabel: VxLabel = {
        let label = VxLabel()
        let imageAttachment = NSTextAttachment()
        label.setFont(viewModel.configuration.font, size: 12, weight: .medium)
        label.textColor = viewModel.configuration.paywallType == VxMainPaywallTypes.v1.rawValue ? cancelAnytimeForegroundColor : .white
        label.text = VxLocalizables.Subscription.cancelableInfoText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var cancelAnytimeIcon: UIImageView = {
        let imageView = UIImageView()
        if viewModel.configuration.paywallType == VxMainPaywallTypes.v1.rawValue {
            let image = UIImage(systemName: "clock.arrow.circlepath")
            imageView.image = image?.withTintColor(.gray)
        }else{
            let image = UIImage(named: "secure_restore_icon", in: .module, compatibleWith: nil)
            imageView.image = image
        }
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var cancelAnytimeIconVerticalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    //MARK: - BottomButtonStack End
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
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(restoreButtonTapped))
        label.addGestureRecognizer(tapGesture)
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
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(termsButtonTapped))
        label.addGestureRecognizer(tapGesture)
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
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(privacyButtonTapped))
        label.addGestureRecognizer(tapGesture)
        return label
    }()

    
    private lazy var privacyReedemCodeSeperator: VxLabel = {
        let label = VxLabel()
        label.text = "|"
        label.setFont(.custom("Manrope"), size: 12, weight: .medium)
        label.textColor = UIColor.colorConverter("535353")
        return label
    }()
    
    private lazy var reedemCodaButton: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        label.text = VxLocalizables.Subscription.reedemCode
        label.setFont(.custom("Manrope"), size: 12, weight: .medium)
        label.numberOfLines = 1
        label.textColor = UIColor.colorConverter("535353")
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(reedemCodaButtonTapped))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    @objc private func restoreButtonTapped() {
        guard self.viewModel.loadingStatePublisher.value == false else { return }
        self.viewModel.restoreAction()
    }
    
    @objc private func termsButtonTapped() {
        VxHub.shared.showEula(isFullScreen: false)
    }
    
    @objc private func privacyButtonTapped() {
        VxHub.shared.showPrivacy(isFullScreen: false)
    }
    
    @objc private func reedemCodaButtonTapped() {
        viewModel.onReedemCodaButtonTapped?()
    }
    
    //MARK: - Restore Buttons End
    
    //MARK: - BottomPageSpacer
    private lazy var bottomPageSpacerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    //MARK: - BottomPageSpacer End
    
    private var topSectionHeightConstraint: NSLayoutConstraint?
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerTimeObserver: Any?
    private var notificationObservers: Set<AnyCancellable> = []
    
    private lazy var videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var videoBackgroundStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var bottomBlackView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var gradientOverlayView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "landing_bg", in: .module, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    public init(frame: CGRect = .zero, viewModel: VxMainSubscriptionViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        self.helper.initalizeLayoutHelper { // TODO: - Find better way
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.setupUI()
                self.setupBindables()
                self.setupTableDataSource()
                self.applyChanges()
                self.constructHiearchy()
            }
        }
    }
    
    private func setupUI() {
        self.backgroundColor = viewModel.configuration.backgroundColor
        descriptionItemViews = viewModel.configuration.descriptionItems.map { item in
            VxPaywallDescriptionItem(
                imageSystemName: item.image,
                description: item.text,
                font: viewModel.configuration.descriptionFont,
                textColor: viewModel.configuration.textColor,
                fontSize: 14,
                iconFrameSize: 16,
                iconBoundsSize: 16,
                fontWeight: .medium
            )
        }
        
        restoreButton.setFont(viewModel.configuration.font, size: 12, weight: .medium)
        termsButton.setFont(viewModel.configuration.font, size: 12, weight: .medium)
        privacyButton.setFont(viewModel.configuration.font, size: 12, weight: .medium)
                
        restoreButton.tintColor = UIColor.gray
        termsButton.tintColor = UIColor.gray
        privacyButton.tintColor = UIColor.gray
        restoreTermsSeperator.textColor = UIColor.gray
        termsPrivacySeperator.textColor = UIColor.gray
        privacyReedemCodeSeperator.textColor = UIColor.gray
        self.closeButton.isHidden = !viewModel.configuration.isCloseButtonEnabled
    }
    
    private func constructHiearchy() {
        if viewModel.configuration.videoBundleName != nil {
            backgroundImageView.isHidden = true
            
            addSubview(videoBackgroundStackView)
            videoBackgroundStackView.translatesAutoresizingMaskIntoConstraints = false
            
            videoBackgroundStackView.addArrangedSubview(videoContainerView)
            videoBackgroundStackView.addArrangedSubview(bottomBlackView)
            
            if viewModel.configuration.showGradientVideoBackground {
                addSubview(gradientOverlayView)
                gradientOverlayView.translatesAutoresizingMaskIntoConstraints = false
            }
            
            var constraints = [
                videoBackgroundStackView.topAnchor.constraint(equalTo: topAnchor),
                videoBackgroundStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                videoBackgroundStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                videoBackgroundStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                videoContainerView.heightAnchor.constraint(equalTo: videoBackgroundStackView.heightAnchor,
                    multiplier: viewModel.configuration.videoHeightMultiplier)
            ]
            
            if viewModel.configuration.showGradientVideoBackground {
                constraints += [
                    gradientOverlayView.topAnchor.constraint(equalTo: topAnchor),
                    gradientOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -5),
                    gradientOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 5),
                    gradientOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
                ]
            }
            
            NSLayoutConstraint.activate(constraints)
            
            setupVideoPlayer()
        }
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        mainVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundImageView)
        addSubview(mainVerticalStackView)
        addSubview(closeButton)
        
        self.productsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.productsTableView.delegate = self
        self.productsTableView.rowHeight = 72
        self.productsTableView.separatorColor = UIColor.clear
        self.productsTableView.registerCell(cellType: VxMainPaywallTableViewCell.self)
        
        mainVerticalStackView.addArrangedSubview(UIView.flexibleSpacer())
        mainVerticalStackView.addArrangedSubview(descriptionLabelHorizontalStackView)
        let totalPaddingWidth = (UIScreen.main.bounds.width - 290)
        descriptionLabelHorizontalStackView.addArrangedSubview(UIView.spacer(width: totalPaddingWidth / 2))
        descriptionLabelHorizontalStackView.addArrangedSubview(descriptionLabelVerticalContainerStackView)
        descriptionLabelHorizontalStackView.addArrangedSubview(UIView.spacer(width: totalPaddingWidth / 2))
        
        descriptionLabelVerticalContainerStackView.addArrangedSubview(descrptionTopTitle)
        descriptionLabelVerticalContainerStackView.addArrangedSubview(UIView.spacer(height: 12))
        descriptionItemViews.forEach { item in
            descriptionLabelVerticalContainerStackView.addArrangedSubview(item)
        }
        
        mainVerticalStackView.addArrangedSubview(UIView.spacer(height: 12))
        mainVerticalStackView.addArrangedSubview(productsTableViewHorizontalStackView)
        
        productsTableViewHorizontalStackView.addArrangedSubview(UIView.spacer(width: 24))
        productsTableViewHorizontalStackView.addArrangedSubview(productsTableView)
        productsTableViewHorizontalStackView.addArrangedSubview(UIView.spacer(width: 24))
        
        mainVerticalStackView.addArrangedSubview(recurringCoinInfoHorizontalStack)
        mainVerticalStackView.addArrangedSubview(UIView.spacer(height: 8))
        
        recurringCoinInfoHorizontalStack.addArrangedSubview(UIView.spacer(width: 24))
        recurringCoinInfoHorizontalStack.addArrangedSubview(recurringCoinInfoVerticalStack)
        recurringCoinInfoHorizontalStack.addArrangedSubview(UIView.spacer(width: 24))
        recurringCoinInfoVerticalStack.addArrangedSubview(recurringCoinInfoLabel)
        
        mainVerticalStackView.addArrangedSubview(productsTableToBottomStackPadding)
        mainVerticalStackView.addArrangedSubview(bottomButtonStackHorizontalStack)
        bottomButtonStackHorizontalStack.addArrangedSubview(UIView.spacer(width: 24))
        bottomButtonStackHorizontalStack.addArrangedSubview(bottomButtonStack)
        bottomButtonStackHorizontalStack.addArrangedSubview(UIView.spacer(width: 24))
        bottomButtonStack.addArrangedSubview(mainActionButton)
        
        bottomButtonStack.addArrangedSubview(cancelAnytimeVerticalStack)
        cancelAnytimeVerticalStack.addArrangedSubview(cancelAnytimeHorizontalStack)
//        cancelAnytimeHorizontalStack.addArrangedSubview(UIView.spacer(width: 8))
        cancelAnytimeHorizontalStack.addArrangedSubview(cancelAnytimeIconVerticalStack)
        cancelAnytimeIconVerticalStack.addArrangedSubview(cancelAnytimeIcon)
        cancelAnytimeIconVerticalStack.addArrangedSubview(UIView.flexibleSpacer())
        cancelAnytimeHorizontalStack.addArrangedSubview(cancelAnytimeLabel)
//        cancelAnytimeHorizontalStack.addArrangedSubview(UIView.spacer(width: 8))
        mainVerticalStackView.addArrangedSubview(mainActionToRestoreStackPadding)
        
        mainVerticalStackView.addArrangedSubview(termsButtonVerticalStack)
        termsButtonVerticalStack.addArrangedSubview(termsHorizontalButtonStack)
        termsHorizontalButtonStack.addArrangedSubview(UIView.spacer(width: 4))
        termsHorizontalButtonStack.addArrangedSubview(self.restoreButton)
        termsHorizontalButtonStack.addArrangedSubview(self.restoreTermsSeperator)
        termsHorizontalButtonStack.addArrangedSubview(self.termsButton)
        termsHorizontalButtonStack.addArrangedSubview(self.termsPrivacySeperator)
        termsHorizontalButtonStack.addArrangedSubview(self.privacyButton)
//        termsHorizontalButtonStack.addArrangedSubview(UIView.spacer(width: 4))
        termsHorizontalButtonStack.addArrangedSubview(self.privacyReedemCodeSeperator)
        termsHorizontalButtonStack.addArrangedSubview(self.reedemCodaButton)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            mainVerticalStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            mainVerticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: 0),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            productsTableView.heightAnchor.constraint(equalToConstant: 148),
            
            mainActionButton.heightAnchor.constraint(equalToConstant: 48),
            mainActionToRestoreStackPadding.heightAnchor.constraint(equalToConstant: 16),
            productsTableToBottomStackPadding.heightAnchor.constraint(equalToConstant: 8),
            cancelAnytimeIconVerticalStack.widthAnchor.constraint(equalToConstant: 16),
            cancelAnytimeIcon.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        self.restoreButton.setContentHuggingPriority(.required, for: .horizontal)
        self.termsButton.setContentHuggingPriority(.required, for: .horizontal)
        self.privacyButton.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private func setupBindables() {
        viewModel.selectedPackagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedPackage in
                guard let self = self else { return }
                if let renewalBonus = viewModel.selectedPackagePublisher.value?.renewalBonus,
                   renewalBonus != 0 {
                    self.recurringCoinInfoLabel.text = VxLocalizables.Subscription.V2.recurringCoinDescriptionLabel
                    self.recurringCoinInfoHorizontalStack.layer.opacity = 1
                    self.recurringCoinInfoLabel.replaceValues(["\(renewalBonus)"])
                }else{
                    self.recurringCoinInfoHorizontalStack.layer.opacity = 0
                }
                self.applyChanges()
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
    
    private func applyChanges() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        productsTableView.isScrollEnabled = viewModel.cellViewModels.count > 2
        snapshot.appendItems(viewModel.cellViewModels, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupTableDataSource() {
        dataSource = UITableViewDiffableDataSource(
            tableView: self.productsTableView,
            cellProvider: { [weak self] tableView, indexPath, viewModel in
                guard self != nil else { return UITableViewCell() }
                let cell = tableView.dequeueReusableCell(with: VxMainPaywallTableViewCell.self, for: indexPath)
                cell.selectionStyle = .none
                cell.configure(
                    with: viewModel,
                    tintColor: UIColor.colorConverter("BE0DA7"),
                    paywallType: .v2)
                return cell
            })
    }
    
    private func setupVideoPlayer() {
        guard let videoBundleName = viewModel.configuration.videoBundleName,
              let videoURL = Bundle.main.url(forResource: videoBundleName, withExtension: "mp4") else {
            return
        }
        
        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        self.player = player
        
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resize
        layer.frame = bounds
        self.playerLayer = layer
        
        videoContainerView.layer.insertSublayer(layer, at: 0)
        player.isMuted = true
        player.play()
        
        // Add loop observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        setupVideoNotifications()
    }
    
    @objc private func playerItemDidReachEnd() {
        player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.player?.play()
            }
        }
    }
    
    private func setupVideoNotifications() {
        NotificationCenter.default.publisher(for: UIScene.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.player?.pause()
            }
            .store(in: &notificationObservers)
        
        NotificationCenter.default.publisher(for: UIScene.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.player?.play()
            }
            .store(in: &notificationObservers)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        buttonGradientLayer?.frame = mainActionButton.bounds
        
        if let playerLayer = playerLayer {
            playerLayer.frame = videoContainerView.bounds
        }
    }
    
    public func viewWillDisappear() {
        player?.pause()
    }
    
    deinit {
        player?.pause()
        player = nil
    }
    
    public func viewDidAppear() {
        player?.play()
    }
}
extension VxMainSubscriptionV2RootView : UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel.loadingStatePublisher.value == false else { return }
        guard let selectedCellIdentifier = self.viewModel.cellViewModels[indexPath.row].identifier else { return }
        viewModel.handleProductSelection(identifier: selectedCellIdentifier)
    }
}

public class VxLoadingButton: UIButton {
    private var originalTitle: String?
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        return indicator
    }()
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                originalTitle = title(for: .normal)
                setTitle("", for: .normal)
                activityIndicator.startAnimating()
                isEnabled = false
            } else {
                setTitle(originalTitle, for: .normal)
                activityIndicator.stopAnimating()
                isEnabled = true
            }
        }
    }
}
