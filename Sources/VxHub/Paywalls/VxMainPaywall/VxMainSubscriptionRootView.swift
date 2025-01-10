//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import UIKit

final public class VxMainSubscriptionRootView: VxNiblessView {

    private let viewModel: VxMainSubscriptionViewModel
    
    private var dataSource: DataSource?
    typealias DataSource = UITableViewDiffableDataSource<VxMainSubscriptionDataSourceSection, VxMainSubscriptionDataSourceModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<VxMainSubscriptionDataSourceSection, VxMainSubscriptionDataSourceModel>

    //MARK: - Base Components
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
        label.text = "VxHub 13123123123123"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
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
            VxPaywallDescriptionItem(imageSystemName: "checkmark.circle.fill", description: "Unlimited AccessUnlimited AccessUnlimited AccessUnlimited AccessUnlimited AccessUnlimited AccessUnlimited AccessUnlimited AccessUnlimited AccessUnlimited AccessUnlimited AccessUnlimited AccessUnlimited AccessUnlimited AccessUnlimited Access"),
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
        freeTrialSwitch.isOn = true
        return freeTrialSwitch
    }()

    private lazy var freeTrialSwitchHorizontalSpacerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var freeTrialSwitchLabel: UILabel = {
        let label = UILabel()
        label.text = "Free Trial"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
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
        configuration.title = "Main Action"
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(mainActionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func mainActionButtonTapped() {
        
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
        
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: " Cancel Anytime"))
        
        label.attributedText = attributedString
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
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
        button.setTitle("Restore", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
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
        button.setTitle("Terms of Use", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
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
        button.setTitle("Privacy Policy", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(privacyButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc private func restoreButtonTapped() {
        print("Restore tapped")
    }

    @objc private func termsButtonTapped() {
        print("Terms of Use tapped")
    }

    @objc private func privacyButtonTapped() {
        print("Privacy Policy tapped")
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
        self.setupUI()
        self.constructHiearchy()
        self.setupBindables()
        self.setupTableDataSource()
        self.initializeDataSource()
    }
    
    private func setupUI() {
        backgroundColor = viewModel.configuration.backgroundColor
        
        // Update top section
        topSectionImageView.image = viewModel.configuration.topImage
        topSectionTitleLabel.text = viewModel.configuration.title
        topSectionTitleLabel.font = viewModel.configuration.titleFont
        
        // Update description items
        descriptionItemViews = viewModel.configuration.descriptionItems.map { item in
            VxPaywallDescriptionItem(
                imageSystemName: item.image,
                description: item.text,
                font: viewModel.configuration.descriptionItemFont
            )
        }
        
        // Update free trial stack border
        freeTrialSwitchMainVerticalStack.layer.borderColor = viewModel.configuration.freeTrialStackBorderColor.cgColor
        
        // Update main action button
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = viewModel.configuration.mainButtonColor
        configuration.baseForegroundColor = .white
        configuration.title = "Main Action"
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        mainActionButton.configuration = configuration
        mainActionButton.titleLabel?.font = viewModel.configuration.mainButtonFont
        
        baseScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
        freeTrialSwitchContainerView.translatesAutoresizingMaskIntoConstraints = false
        freeTrialSwitch.translatesAutoresizingMaskIntoConstraints = false
    }

    private func constructHiearchy() {
        self.productsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.productsTableView.delegate = self
        self.productsTableView.rowHeight = 80
        self.productsTableView.separatorColor = UIColor.clear
        self.productsTableView.registerCell(cellType: VxMainPaywallTableViewCell.self)
        
        let helper = VxLayoutHelper()
        addSubview(baseScrollView)
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
        
        mainVerticalStackView.addArrangedSubview(termsButtonVerticalStack)
        termsButtonVerticalStack.addArrangedSubview(termsHorizontalButtonStack)
        termsHorizontalButtonStack.addArrangedSubview(self.restoreButton)
        termsHorizontalButtonStack.addArrangedSubview(self.restoreTermsSeperator)
        termsHorizontalButtonStack.addArrangedSubview(self.termsButton)
        termsHorizontalButtonStack.addArrangedSubview(self.termsPrivacySeperator)
        termsHorizontalButtonStack.addArrangedSubview(self.privacyButton)
        
        
        mainVerticalStackView.addArrangedSubview(mainActionToRestoreStackPadding)
        mainVerticalStackView.addArrangedSubview(bottomPageSpacerView)
        NSLayoutConstraint.activate([
            baseScrollView.topAnchor.constraint(equalTo: self.topAnchor),
            baseScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            baseScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            baseScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            mainVerticalStackView.topAnchor.constraint(equalTo: self.baseScrollView.topAnchor, constant: helper.safeAreaTopPadding + 42),
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
            
            descriptionToFreeTrialSwitchPadding.heightAnchor.constraint(equalToConstant: 24),
            freeTrialToProductsTablePadding.heightAnchor.constraint(equalToConstant: 12),
            mainActionButton.heightAnchor.constraint(equalToConstant: 48),
            bottomButtonStack.heightAnchor.constraint(equalToConstant: 82),
            mainActionToRestoreStackPadding.heightAnchor.constraint(equalToConstant: 12),
            productsTableToBottomStackPadding.heightAnchor.constraint(equalToConstant: 16),
            topSectionToDescriptionPadding.heightAnchor.constraint(equalToConstant: 32)
        ])
        freeTrialSwitchLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func setupBindables() {

    }
    
    private func initializeDataSource() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        let cellViewModels = [
            VxMainSubscriptionDataSourceModel(id: 1, identifier: "monthly", title: "Monthly Plan", description: "Monthly subscription", localizedPrice: "$9.99", weeklyPrice: "", monthlyPrice: "$9.99", dailyPrice: "", discountAmount: 0),
            VxMainSubscriptionDataSourceModel(id: 2, identifier: "yearly", title: "Yearly Plan", description: "Yearly subscription", localizedPrice: "$99.99", weeklyPrice: "", monthlyPrice: "$8.33", dailyPrice: "", discountAmount: 20)
        ]
        productsTableView.isScrollEnabled = cellViewModels.count > 2
        snapshot.appendItems(cellViewModels, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupTableDataSource() {
        dataSource = UITableViewDiffableDataSource(
            tableView: self.productsTableView,
            cellProvider: { [weak self] tableView, indexPath, viewModel in
                guard let self = self else { return UITableViewCell() }
                let cell = tableView.dequeueReusableCell(with: VxMainPaywallTableViewCell.self, for: indexPath)
                cell.selectionStyle = .none
                cell.configure(with: self.viewModel.configuration)
                return cell
            })
    }
}

extension String { //TODO: - Move me
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}

extension VxMainSubscriptionRootView : UITableViewDelegate {}
