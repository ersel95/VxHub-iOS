//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import Foundation
import UIKit


public final class VxMainSubscriptionRootView: VxNiblessView {

    private let viewModel: VxMainSubscriptionViewModel

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
    //MARK: - Top Section End
    
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
    
    private func calculateDecsriptionStackHeight() -> CGFloat{
        let items = [
            VxPaywallDescriptionItem(imageSystemName: "checkmark.circle.fill", description: "Unlimited Access"),
            VxPaywallDescriptionItem(imageSystemName: "checkmark.circle.fill", description: "Premium Features"),
            VxPaywallDescriptionItem(imageSystemName: "checkmark.circle.fill", description: "No Ads"),
        ]
        var totalHeight = 16.0
        totalHeight += 44 * Double(items.count)
        debugPrint("Total height is",totalHeight)
        return totalHeight
    }

    
    //MARK: - Description Label Section End

    //MARK: - Free Trial Switch Section
    private lazy var freeTrialSwitchMainVerticalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
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
    //MARK: - Free Trial Switch Section End

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
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        baseScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func constructHiearchy() {
        let helper = VxLayoutHelper()
        addSubview(baseScrollView)
        baseScrollView.addSubview(mainVerticalStackView)
        
        mainVerticalStackView.addArrangedSubview(topSectionHorizontalStackView)
        topSectionHorizontalStackView.addArrangedSubview(topSectionVerticalStackView)
        topSectionVerticalStackView.addArrangedSubview(topSectionImageView)
        topSectionVerticalStackView.addArrangedSubview(topSectionTitleLabel)
        
        mainVerticalStackView.addArrangedSubview(descriptionLabelVerticalContainerStackView)
        descriptionLabelVerticalContainerStackView.addArrangedSubview(descriptionLabelVerticalStackView)
        
        descriptionItemViews.forEach { item in
            descriptionLabelVerticalStackView.addArrangedSubview(item)
        }

        mainVerticalStackView.addArrangedSubview(freeTrialSwitchMainVerticalStack)
        freeTrialSwitchMainVerticalStack.addArrangedSubview(freeTrialSwitchMainHorizontalStack)
        freeTrialSwitchMainHorizontalStack.addArrangedSubview(freeTrialSwitchLabel)
        freeTrialSwitchMainHorizontalStack.addArrangedSubview(freeTrialSwitchHorizontalSpacerView)
        freeTrialSwitchMainHorizontalStack.addArrangedSubview(freeTrialSwitch)

        self.mainVerticalStackView.addArrangedSubview(bottomPageSpacerView)
        
        NSLayoutConstraint.activate([
            baseScrollView.topAnchor.constraint(equalTo: self.topAnchor),
            baseScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            baseScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            baseScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            mainVerticalStackView.topAnchor.constraint(equalTo: self.baseScrollView.topAnchor, constant: helper.safeAreaTopPadding),
            mainVerticalStackView.leadingAnchor.constraint(equalTo: self.baseScrollView.leadingAnchor, constant: 24),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: self.baseScrollView.trailingAnchor, constant: 24),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: self.baseScrollView.bottomAnchor, constant: helper.safeAreaBottomPadding),
            mainVerticalStackView.widthAnchor.constraint(equalTo: self.baseScrollView.widthAnchor, constant: -48),

            topSectionVerticalStackView.heightAnchor.constraint(equalToConstant: 130),
            topSectionImageView.heightAnchor.constraint(equalToConstant: 96),
            topSectionImageView.widthAnchor.constraint(equalToConstant: 96),
            
            descriptionLabelVerticalContainerStackView.heightAnchor.constraint(equalToConstant: self.calculateDecsriptionStackHeight()),
            descriptionLabelVerticalStackView.topAnchor.constraint(equalTo: descriptionLabelVerticalContainerStackView.topAnchor,constant: 8),
            descriptionLabelVerticalStackView.leadingAnchor.constraint(equalTo: descriptionLabelVerticalContainerStackView.leadingAnchor),
            descriptionLabelVerticalStackView.trailingAnchor.constraint(equalTo: descriptionLabelVerticalContainerStackView.trailingAnchor,constant: -8),
            descriptionLabelVerticalStackView.bottomAnchor.constraint(equalTo: descriptionLabelVerticalContainerStackView.bottomAnchor),
            
            freeTrialSwitchMainHorizontalStack.topAnchor.constraint(equalTo: freeTrialSwitchMainVerticalStack.topAnchor, constant: 10),
            freeTrialSwitchMainHorizontalStack.bottomAnchor.constraint(equalTo: freeTrialSwitchMainVerticalStack.bottomAnchor, constant: -10),
            freeTrialSwitchMainHorizontalStack.leadingAnchor.constraint(equalTo: freeTrialSwitchMainVerticalStack.leadingAnchor, constant: 20),
            freeTrialSwitchMainHorizontalStack.trailingAnchor.constraint(equalTo: freeTrialSwitchMainVerticalStack.trailingAnchor, constant: -20),
            freeTrialSwitch.widthAnchor.constraint(equalToConstant: 40),
        ])
    }

    private func setupBindables() {

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
