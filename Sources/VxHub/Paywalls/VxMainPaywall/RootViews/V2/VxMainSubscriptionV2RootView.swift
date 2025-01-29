//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import UIKit
import Combine

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
        imageView.image = UIImage(named:viewModel.configuration.backgroundImageName ?? "")
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
        let image = UIImage(systemName: "xmark", withConfiguration: config)?.withTintColor(.gray, renderingMode: .alwaysOriginal)
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
        label.text = "Unlock Features"
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
        label.setFont(viewModel.configuration.font, size: 12, weight: .medium)
        label.textColor = UIColor.colorConverter("B4B4B4")
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - BottomButtonStack
    private lazy var bottomButtonStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var mainActionButton: UIButton = {
        let button = UIButton(type: .system)
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
        if isLoading {
//            mainActionButton.isLoading = true
            self.closeButton.isEnabled = false
            self.closeButton.isHidden = true
        }else{
//            mainActionButton.isLoading = false
            self.closeButton.isEnabled = true
            self.closeButton.isHidden = false
        }
        mainActionButton.isEnabled = !isLoading
        closeButton.isEnabled = !isLoading
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
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var cancelAnytimeLabel: VxLabel = {
        let label = VxLabel()
        let imageAttachment = NSTextAttachment()
        label.setFont(viewModel.configuration.font, size: 12, weight: .medium)
        label.textColor = viewModel.configuration.paywallType == VxMainPaywallTypes.v1.rawValue ? cancelAnytimeForegroundColor : .white
        label.text = VxLocalizables.Subscription.cancelableInfoText
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
        stackView.spacing = 6
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(
            NSAttributedString(
                string: VxLocalizables.Subscription.restorePurchaseLabel,
                attributes: [
                    .font: UIFont.custom(viewModel.configuration.font, size: 12, weight: .medium),
                    .foregroundColor: UIColor.gray
                ]
            ),
            for: .normal
        )
        button.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var restoreTermsSeperator: VxLabel = {
        let label = VxLabel()
        label.text = "|"
        label.setFont(viewModel.configuration.font, size: 12, weight: .medium)
        return label
    }()
    
    private lazy var termsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(
            NSAttributedString(
                string: VxLocalizables.Subscription.termsOfUse,
                attributes: [
                    .font: UIFont.custom(viewModel.configuration.font, size: 12, weight: .medium),
                    .foregroundColor: UIColor.gray
                ]
            ),
            for: .normal
        )
        button.addTarget(self, action: #selector(termsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var termsPrivacySeperator: VxLabel = {
        let label = VxLabel()
        label.text = "|"
        label.setFont(viewModel.configuration.font, size: 12, weight: .medium)
        label.textColor = UIColor.gray.withAlphaComponent(0.5)
        return label
    }()
    
    private lazy var privacyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(
            NSAttributedString(
                string: VxLocalizables.Subscription.privacyPol,
                attributes: [
                    .font: UIFont.custom(viewModel.configuration.font, size: 12, weight: .medium),
                    .foregroundColor: UIColor.gray
                ]
            ),
            for: .normal
        )
        button.addTarget(self, action: #selector(privacyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func restoreButtonTapped() {
        self.viewModel.restoreAction()
    }
    
    @objc private func termsButtonTapped() {
        VxHub.shared.showEula(isFullScreen: false)
    }
    
    @objc private func privacyButtonTapped() {
        VxHub.shared.showPrivacy(isFullScreen: false)
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
    
    public init(frame: CGRect = .zero, viewModel: VxMainSubscriptionViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        self.helper.initalizeLayoutHelper { // TODO: - Find better way
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.setupUI()
                self.constructHiearchy()
                self.setupBindables()
                self.setupTableDataSource()
                self.applyChanges()
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
        
        restoreButton.titleLabel?.font = .custom(viewModel.configuration.font, size: 12, weight: .medium)
        termsButton.titleLabel?.font = .custom(viewModel.configuration.font, size: 12, weight: .medium)
        privacyButton.titleLabel?.font = .custom(viewModel.configuration.font, size: 12, weight: .medium)
                
        restoreButton.tintColor = UIColor.gray
        termsButton.tintColor = UIColor.gray
        privacyButton.tintColor = UIColor.gray
        restoreTermsSeperator.textColor = UIColor.gray
        termsPrivacySeperator.textColor = UIColor.gray
        
    }
    
    private func constructHiearchy() {
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
        descriptionItemViews.forEach { item in
            descriptionLabelVerticalContainerStackView.addArrangedSubview(item)
        }
        
        mainVerticalStackView.addArrangedSubview(productsTableView)
        
        mainVerticalStackView.addArrangedSubview(recurringCoinInfoHorizontalStack)
        recurringCoinInfoHorizontalStack.addArrangedSubview(recurringCoinInfoVerticalStack)
        recurringCoinInfoVerticalStack.addArrangedSubview(recurringCoinInfoLabel)
        
        mainVerticalStackView.addArrangedSubview(productsTableToBottomStackPadding)
        mainVerticalStackView.addArrangedSubview(bottomButtonStack)
        bottomButtonStack.addArrangedSubview(mainActionButton)
        
        bottomButtonStack.addArrangedSubview(cancelAnytimeVerticalStack)
        cancelAnytimeVerticalStack.addArrangedSubview(cancelAnytimeHorizontalStack)
        cancelAnytimeHorizontalStack.addArrangedSubview(cancelAnytimeIcon)
        cancelAnytimeHorizontalStack.addArrangedSubview(cancelAnytimeLabel)
        mainVerticalStackView.addArrangedSubview(mainActionToRestoreStackPadding)
        
        mainVerticalStackView.addArrangedSubview(termsButtonVerticalStack)
        termsButtonVerticalStack.addArrangedSubview(termsHorizontalButtonStack)
        termsHorizontalButtonStack.addArrangedSubview(self.restoreButton)
        termsHorizontalButtonStack.addArrangedSubview(self.restoreTermsSeperator)
        termsHorizontalButtonStack.addArrangedSubview(self.termsButton)
        termsHorizontalButtonStack.addArrangedSubview(self.termsPrivacySeperator)
        termsHorizontalButtonStack.addArrangedSubview(self.privacyButton)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            mainVerticalStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            mainVerticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -24),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16 + helper.safeAreaTopPadding),
            closeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            productsTableView.heightAnchor.constraint(equalToConstant: 148),
            
            mainActionButton.heightAnchor.constraint(equalToConstant: 48),
            bottomButtonStack.heightAnchor.constraint(equalToConstant: 82),
            mainActionToRestoreStackPadding.heightAnchor.constraint(equalToConstant: 12),
            productsTableToBottomStackPadding.heightAnchor.constraint(equalToConstant: 8),
            cancelAnytimeIcon.widthAnchor.constraint(equalToConstant: 16),
            cancelAnytimeVerticalStack.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    private func setupBindables() {
        viewModel.selectedPackagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedPackage in
                guard let self = self else { return }
                
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
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        buttonGradientLayer?.frame = mainActionButton.bounds
    }
}
extension VxMainSubscriptionV2RootView : UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel.loadingStatePublisher.value == false else { return }
        guard let selectedCellIdentifier = self.viewModel.cellViewModels[indexPath.row].identifier else { return }
        viewModel.handleProductSelection(identifier: selectedCellIdentifier)
    }
}
