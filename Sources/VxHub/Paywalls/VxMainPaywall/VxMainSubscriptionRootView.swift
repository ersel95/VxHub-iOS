//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import UIKit
import Combine

final public class VxMainSubscriptionRootView: VxNiblessView {

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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var baseScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
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
    
    //MARK: - Top Section
    private lazy var topSectionHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()

    private lazy var topSectionVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()

    private lazy var topSectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "square.fill")
        return imageView
    }()

    private lazy var topSectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.configuration.title
        label.font = .custom(viewModel.configuration.fontFamily, size: 24, weight: .bold)
        label.textColor = viewModel.configuration.textColor
        return label
    }()
    
    private lazy var topSectionToDescriptionPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    //MARK: - Description Label Section
    private lazy var descriptionLabelVerticalContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var descriptionLabelVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var descriptionItemViews: [VxPaywallDescriptionItem] = {
        let items = [
            VxPaywallDescriptionItem(imageSystemName: "checkmark.circle.fill", description: "Unlimited Access"),
            VxPaywallDescriptionItem(imageSystemName: "checkmark.circle.fill", description: "Premium Features"),
            VxPaywallDescriptionItem(imageSystemName: "checkmark.circle.fill", description: "No Ads"),
        ]
        return items
    }()
    
    private lazy var descriptionItemsSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    //MARK: - Description Label Section End
    
    private lazy var descriptionToFreeTrialSwitchPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    //MARK: - Free Trial Switch Section
    private lazy var freeTrialSwitchMainVerticalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.red.cgColor
        stackView.layer.cornerRadius = 16
        return stackView
    }()

    private lazy var freeTrialSwitchMainHorizontalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var freeTrialSwitchContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var freeTrialSwitch: UISwitch = {
        let freeTrialSwitch = UISwitch()
        freeTrialSwitch.isOn = false
        freeTrialSwitch.addTarget(self, action: #selector(handleFreeTrialSwitchChange), for: .valueChanged)
        return freeTrialSwitch
    }()

    private lazy var freeTrialSwitchHorizontalSpacerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var freeTrialSwitchLabel: UILabel = {
        let label = UILabel()
        label.text = VxLocalizables.Subscription.freeTrailEnabledLabel
        label.font = .custom(viewModel.configuration.fontFamily, size: 14, weight: .medium)
        label.textColor = viewModel.configuration.textColor
        return label
    }()

    private lazy var freeTrialSwitchTopPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var freeTrialSwitchBottomPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var freeTrialSwitchLeftPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var freeTrialSwitchRightPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    //MARK: - Free Trial Switch Section End
    
    private lazy var freeTrialToProductsTablePadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

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
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .purple
        configuration.baseForegroundColor = .white
        configuration.title = VxLocalizables.Subscription.subscribeButtonLabel
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        configuration.showsActivityIndicator = false
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .custom(viewModel.configuration.fontFamily, size: 16, weight: .semibold)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(mainActionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func mainActionButtonTapped() {
        self.viewModel.purchaseAction()
    }

    private func setLoadingState(_ isLoading: Bool) {
        var config = mainActionButton.configuration
        config?.showsActivityIndicator = isLoading
        config?.title = isLoading ? "" : VxLocalizables.Subscription.subscribeButtonLabel
        mainActionButton.configuration = config
        mainActionButton.isEnabled = !isLoading
        closeButton.isEnabled = !isLoading
    }

    private lazy var mainActionButtonSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var cancelAnytimeLabel: UILabel = {
        let label = UILabel()
        let imageAttachment = NSTextAttachment()
        let image = UIImage(systemName: "clock.arrow.circlepath")
        imageAttachment.image = image?.withTintColor(.gray)
        
        let font = UIFont.custom(viewModel.configuration.fontFamily, size: 12, weight: .medium)
        let mid = font.capHeight / 2
        imageAttachment.bounds = CGRect(x: 0, y: -mid/2, width: font.lineHeight, height: font.lineHeight)
        
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(
            string: " " + VxLocalizables.Subscription.cancelableInfoText,
            attributes: [
                .font: font,
                .foregroundColor: UIColor.gray
            ]
        ))
        
        label.attributedText = attributedString
        label.textAlignment = .center
        return label
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
        stackView.spacing = 4
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
                    .font: UIFont.custom(viewModel.configuration.fontFamily, size: 12, weight: .medium),
                    .foregroundColor: UIColor.gray
                ]
            ),
            for: .normal
        )
        button.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var restoreTermsSeperator: UILabel = {
        let label = UILabel()
        label.font =  .systemFont(ofSize: 12)
        label.text = "|"
        return label
    }()

    private lazy var termsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(
            NSAttributedString(
                string: VxLocalizables.Subscription.termsOfUse,
                attributes: [
                    .font: UIFont.custom(viewModel.configuration.fontFamily, size: 12, weight: .medium),
                    .foregroundColor: UIColor.gray
                ]
            ),
            for: .normal
        )
        button.addTarget(self, action: #selector(termsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var termsPrivacySeperator: UILabel = {
        let label = UILabel()
        label.font =  .systemFont(ofSize: 12)
        label.text = "|"
        return label
    }()

    private lazy var privacyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(
            NSAttributedString(
                string: VxLocalizables.Subscription.privacyPol,
                attributes: [
                    .font: UIFont.custom(viewModel.configuration.fontFamily, size: 12, weight: .medium),
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
        backgroundColor = viewModel.configuration.backgroundColor
        backgroundImageView.image = viewModel.configuration.backgroundImage
        
        topSectionImageView.image = viewModel.configuration.topImage
        topSectionTitleLabel.text = viewModel.configuration.title
        topSectionTitleLabel.font = .custom(viewModel.configuration.fontFamily, size: 24, weight: .bold)
        
        // Update text colors
        topSectionTitleLabel.textColor = viewModel.configuration.textColor
        
        // Update description items
        descriptionItemViews = viewModel.configuration.descriptionItems.map { item in
            VxPaywallDescriptionItem(
                imageSystemName: item.image,
                description: item.text,
                fontName: viewModel.configuration.fontFamily,
                textColor: viewModel.configuration.textColor
            )
        }
        
        freeTrialSwitchLabel.font = .custom(viewModel.configuration.fontFamily, size: 14, weight: .medium)
        mainActionButton.titleLabel?.font = .custom(viewModel.configuration.fontFamily, size: 16, weight: .semibold)
        cancelAnytimeLabel.font = .custom(viewModel.configuration.fontFamily, size: 12, weight: .medium)
        restoreButton.titleLabel?.font = .custom(viewModel.configuration.fontFamily, size: 12, weight: .medium)
        restoreTermsSeperator.font = .custom(viewModel.configuration.fontFamily, size: 12, weight: .medium)
        termsButton.titleLabel?.font = .custom(viewModel.configuration.fontFamily, size: 12, weight: .medium)
        termsPrivacySeperator.font = .custom(viewModel.configuration.fontFamily, size: 12, weight: .medium)
        privacyButton.titleLabel?.font = .custom(viewModel.configuration.fontFamily, size: 12, weight: .medium)
        freeTrialSwitchMainVerticalStack.layer.borderColor = viewModel.configuration.freeTrialStackBorderColor.cgColor
        
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = viewModel.configuration.mainButtonColor
        configuration.baseForegroundColor = .white
        configuration.title = VxLocalizables.Subscription.subscribeButtonLabel
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        mainActionButton.configuration = configuration
        mainActionButton.titleLabel?.font = .custom(viewModel.configuration.fontFamily, size: 16, weight: .semibold)
        self.freeTrialSwitchMainVerticalStack.isHidden = !self.viewModel.cellViewModels.contains(where: {
            $0.eligibleForFreeTrialOrDiscount ?? false
        })
        
        // Update other labels
        freeTrialSwitchLabel.textColor = viewModel.configuration.textColor
        restoreButton.tintColor = viewModel.configuration.textColor
        termsButton.tintColor = viewModel.configuration.textColor
        privacyButton.tintColor = viewModel.configuration.textColor
        restoreTermsSeperator.textColor = viewModel.configuration.textColor
        termsPrivacySeperator.textColor = viewModel.configuration.textColor
    }

    private func constructHiearchy() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        baseScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
        freeTrialSwitchContainerView.translatesAutoresizingMaskIntoConstraints = false
        freeTrialSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundImageView)
        addSubview(baseScrollView)
        addSubview(closeButton)
        
        self.productsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.productsTableView.delegate = self
        self.productsTableView.rowHeight = 80
        self.productsTableView.separatorColor = UIColor.clear
        self.productsTableView.registerCell(cellType: VxMainPaywallTableViewCell.self)
        
        baseScrollView.addSubview(mainVerticalStackView)
        
        mainVerticalStackView.addArrangedSubview(topSectionHorizontalStackView)
        topSectionHorizontalStackView.addArrangedSubview(topSectionVerticalStackView)
        topSectionVerticalStackView.addArrangedSubview(topSectionImageView)
        topSectionVerticalStackView.addArrangedSubview(topSectionTitleLabel)
        
        mainVerticalStackView.addArrangedSubview(topSectionToDescriptionPadding)
        
        mainVerticalStackView.addArrangedSubview(descriptionLabelVerticalContainerStackView)
        descriptionLabelVerticalContainerStackView.addArrangedSubview(descriptionLabelVerticalStackView)
        
        descriptionItemViews.forEach { item in
            descriptionLabelVerticalStackView.addArrangedSubview(item)
        }
        descriptionLabelVerticalStackView.addArrangedSubview(descriptionItemsSpacer)

        mainVerticalStackView.addArrangedSubview(descriptionToFreeTrialSwitchPadding)
        
        mainVerticalStackView.addArrangedSubview(freeTrialSwitchMainVerticalStack)
        mainVerticalStackView.addArrangedSubview(freeTrialToProductsTablePadding)
        freeTrialSwitchMainVerticalStack.addArrangedSubview(freeTrialSwitchTopPadding)
        freeTrialSwitchMainVerticalStack.addArrangedSubview(freeTrialSwitchMainHorizontalStack)
        freeTrialSwitchMainHorizontalStack.addArrangedSubview(freeTrialSwitchRightPadding)
        freeTrialSwitchMainHorizontalStack.addArrangedSubview(freeTrialSwitchLabel)
        freeTrialSwitchMainHorizontalStack.addArrangedSubview(freeTrialSwitchHorizontalSpacerView)
        freeTrialSwitchMainHorizontalStack.addArrangedSubview(freeTrialSwitchContainerView)
        freeTrialSwitchMainHorizontalStack.addArrangedSubview(freeTrialSwitchLeftPadding)
        freeTrialSwitchContainerView.addSubview(freeTrialSwitch)
        freeTrialSwitchMainVerticalStack.addArrangedSubview(freeTrialSwitchBottomPadding)
        
        mainVerticalStackView.addArrangedSubview(productsTableView)
        mainVerticalStackView.addArrangedSubview(productsTableToBottomStackPadding)
        mainVerticalStackView.addArrangedSubview(bottomButtonStack)
        bottomButtonStack.addArrangedSubview(mainActionButton)
        bottomButtonStack.addArrangedSubview(cancelAnytimeLabel)
        mainVerticalStackView.addArrangedSubview(mainActionToRestoreStackPadding)

        mainVerticalStackView.addArrangedSubview(termsButtonVerticalStack)
        termsButtonVerticalStack.addArrangedSubview(termsHorizontalButtonStack)
        termsHorizontalButtonStack.addArrangedSubview(self.restoreButton)
        termsHorizontalButtonStack.addArrangedSubview(self.restoreTermsSeperator)
        termsHorizontalButtonStack.addArrangedSubview(self.termsButton)
        termsHorizontalButtonStack.addArrangedSubview(self.termsPrivacySeperator)
        termsHorizontalButtonStack.addArrangedSubview(self.privacyButton)
        
        
        mainVerticalStackView.addArrangedSubview(bottomPageSpacerView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            baseScrollView.topAnchor.constraint(equalTo: self.topAnchor),
            baseScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            baseScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            baseScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16 + helper.safeAreaTopPadding),
            closeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            mainVerticalStackView.topAnchor.constraint(equalTo: self.baseScrollView.topAnchor, constant: helper.adaptiveHeight(42) + helper.safeAreaTopPadding),
            mainVerticalStackView.leadingAnchor.constraint(equalTo: self.baseScrollView.leadingAnchor, constant: 24),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: self.baseScrollView.trailingAnchor, constant: 24),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: self.baseScrollView.bottomAnchor, constant: helper.safeAreaBottomPadding),
            mainVerticalStackView.widthAnchor.constraint(equalTo: self.baseScrollView.widthAnchor, constant: -48),

            topSectionVerticalStackView.heightAnchor.constraint(equalToConstant: 130),
            topSectionImageView.heightAnchor.constraint(equalToConstant: 96),
            topSectionImageView.widthAnchor.constraint(equalToConstant: 96),
            
            
            descriptionLabelVerticalStackView.topAnchor.constraint(equalTo: descriptionLabelVerticalContainerStackView.topAnchor,constant: 8),
            descriptionLabelVerticalStackView.leadingAnchor.constraint(equalTo: descriptionLabelVerticalContainerStackView.leadingAnchor),
            descriptionLabelVerticalStackView.trailingAnchor.constraint(equalTo: descriptionLabelVerticalContainerStackView.trailingAnchor,constant: -8),
            descriptionLabelVerticalStackView.bottomAnchor.constraint(equalTo: descriptionLabelVerticalContainerStackView.bottomAnchor),
            
            freeTrialSwitchMainVerticalStack.heightAnchor.constraint(equalToConstant: 47),
            freeTrialSwitch.leadingAnchor.constraint(equalTo: freeTrialSwitchContainerView.leadingAnchor),
            freeTrialSwitch.trailingAnchor.constraint(equalTo: freeTrialSwitchContainerView.trailingAnchor),
            freeTrialSwitch.centerYAnchor.constraint(equalTo:  freeTrialSwitchContainerView.centerYAnchor),
            freeTrialSwitchContainerView.widthAnchor.constraint(equalToConstant: 48),
            freeTrialSwitchLeftPadding.widthAnchor.constraint(equalToConstant: 20),
            freeTrialSwitchRightPadding.widthAnchor.constraint(equalToConstant: 20),
            freeTrialSwitchTopPadding.heightAnchor.constraint(equalToConstant: 10),
            freeTrialSwitchBottomPadding.heightAnchor.constraint(equalToConstant: 10),
            productsTableView.heightAnchor.constraint(equalToConstant: 148),
            
            descriptionToFreeTrialSwitchPadding.heightAnchor.constraint(equalToConstant: helper.adaptiveHeight(34)),
            freeTrialToProductsTablePadding.heightAnchor.constraint(equalToConstant: 12),
            mainActionButton.heightAnchor.constraint(equalToConstant: 48),
            bottomButtonStack.heightAnchor.constraint(equalToConstant: 82),
            mainActionToRestoreStackPadding.heightAnchor.constraint(equalToConstant: helper.adaptiveHeight(12)),
            productsTableToBottomStackPadding.heightAnchor.constraint(equalToConstant: 16),
            topSectionToDescriptionPadding.heightAnchor.constraint(equalToConstant: helper.adaptiveHeight(24))
        ])
        freeTrialSwitchLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func setupBindables() {
        viewModel.selectedPackagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedPackage in
                guard let self = self else { return }
                self.freeTrialSwitch.setOn(selectedPackage?.eligibleForFreeTrialOrDiscount ?? false, animated: true)
                self.applyChanges()
            }
            .store(in: &disposeBag)
        
        viewModel.freeTrialSwitchState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOn in
                self?.freeTrialSwitch.setOn(isOn, animated: true)
                self?.applyChanges()
            }
            .store(in: &disposeBag)
            
        viewModel.loadingStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.setLoadingState(isLoading)
            }
            .store(in: &disposeBag)
    }
    
    @objc private func handleFreeTrialSwitchChange() {
        viewModel.handleFreeTrialSwitchChange(isOn: freeTrialSwitch.isOn)
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
                cell.configure(with: viewModel)
                return cell
            })
    }
}
extension VxMainSubscriptionRootView : UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCellIdentifier = self.viewModel.cellViewModels[indexPath.row].identifier else { return }
        viewModel.handleProductSelection(identifier: selectedCellIdentifier)
    }
}
