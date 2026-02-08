//
//  File.swift
//  VxHub
//
//  Created by furkan on 9.01.2025.
//

import UIKit

final class VxMainPaywallTableViewCell: VxNiblessTableViewCell {
    var model: VxMainSubscriptionDataSourceModel?
    
    let unselectedBorderLineColor = UIColor(red: 167/255, green: 167/255, blue: 167/255, alpha: 1.0)
    let selectedBorderLineColor = UIColor(red: 20/255, green: 140/255, blue: 190/255, alpha: 1.0)
    
    // MARK: - Base Views
    private lazy var mainContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var mainVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layer.cornerRadius = 16
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var mainHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var baseTopPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var baseBottomPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var baseLeftPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var baseRightPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Selected Dot View
    private lazy var selectedDotVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var selectedDotHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var selectedDotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1.0)
        return imageView
    }()
    
    private lazy var selectedDotProductDescriptionPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Product Description View
    private lazy var productDescriptionVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var productDescriptionHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var productDescriptionTitle: VxLabel = {
        let label = VxLabel()
        label.text = "Yearly Accesss"
        label.textColor = UIColor(red: 21/255, green: 33/255, blue: 61/255, alpha: 1.0)
        label.textAlignment = .left
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var productDescriptionTitleHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var productDescriptionTitleHorizontalSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var productDescriptionSubtitleIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gift_coin_icon", in: .module, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var productDescriptionSubtitle: VxLabel = {
        let label = VxLabel()
        label.text = "Unlimited Access to All Features"
        label.textColor = UIColor(red: 21/255, green: 33/255, blue: 61/255, alpha: 1.0)
        label.textAlignment = .left
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var productDescriptionSubtitleHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var productDescriptionSubtitleHorizontalSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var productDescriptionSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Description to Price Spacer
    private lazy var descriptionToPriceSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Price Description View
    private lazy var priceDescriptionVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var priceDescriptionHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var priceDescriptionTitle: VxLabel = {
        let label = VxLabel()
        label.text = "Cheap price"
        label.textColor = UIColor(red: 21/255, green: 33/255, blue: 61/255, alpha: 1.0)
        label.textAlignment = .right
        label.isUserInteractionEnabled = false
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var priceDescriptionTitleHorizontalSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var priceDescriptionTitleHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var priceDescriptionSubtitle: VxLabel = {
        let label = VxLabel()
        label.text = "only 99"
        label.textColor = UIColor(red: 21/255, green: 33/255, blue: 61/255, alpha: 1.0)
        label.textAlignment = .right
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var priceDescriptionSubtitleHorizontalSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var priceDescriptionSubtitleHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var priceDescriptionSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Best Offer Badge
    private lazy var bestOfferBadgeView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "best-offer-badge", in: .module, compatibleWith: nil)
        imageView.tintColor = .yellow
        return imageView
    }()
    
    private lazy var bestOfferBadgeLabel: VxLabel = {
        let label = VxLabel()
        label.text = VxLocalizables.Subscription.bestOfferBadgeLabel
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    private func setupViews() {
        self.mainContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.mainVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
        self.bestOfferBadgeView.translatesAutoresizingMaskIntoConstraints = false
        self.bestOfferBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(mainContainerView)
        self.mainContainerView.addSubview(mainVerticalStackView)
        
        self.mainVerticalStackView.addArrangedSubview(baseTopPadding)
        self.mainVerticalStackView.addArrangedSubview(mainHorizontalStackView)
        self.mainVerticalStackView.addArrangedSubview(baseBottomPadding)
        
        self.mainHorizontalStackView.addArrangedSubview(baseLeftPadding)
        self.mainHorizontalStackView.addArrangedSubview(selectedDotHorizontalStackView)
        self.mainHorizontalStackView.addArrangedSubview(selectedDotVerticalStackView)
        self.selectedDotHorizontalStackView.addArrangedSubview(selectedDotImageView)
        
        self.mainHorizontalStackView.addArrangedSubview(selectedDotProductDescriptionPadding)
        
        self.mainHorizontalStackView.addArrangedSubview(productDescriptionHorizontalStackView)
        self.productDescriptionHorizontalStackView.addArrangedSubview(productDescriptionVerticalStackView)
        
        self.productDescriptionVerticalStackView.addArrangedSubview(productDescriptionTitleHorizontalStackView)
        self.productDescriptionTitleHorizontalStackView.addArrangedSubview(productDescriptionTitle)
        self.productDescriptionTitleHorizontalStackView.addArrangedSubview(productDescriptionTitleHorizontalSpacer)
        
        self.productDescriptionVerticalStackView.addArrangedSubview(productDescriptionSubtitleHorizontalStackView)
        productDescriptionSubtitleHorizontalStackView.addArrangedSubview(productDescriptionSubtitleIcon)
        productDescriptionSubtitleHorizontalStackView.addArrangedSubview(productDescriptionSubtitle)
        productDescriptionSubtitleHorizontalStackView.addArrangedSubview(productDescriptionSubtitleHorizontalSpacer)
        
        //        self.productDescriptionHorizontalStackView.addArrangedSubview(productDescriptionSpacer)
        
        self.mainHorizontalStackView.addArrangedSubview(descriptionToPriceSpacer)
        
        self.mainHorizontalStackView.addArrangedSubview(priceDescriptionHorizontalStackView)
        
        self.priceDescriptionHorizontalStackView.addArrangedSubview(priceDescriptionVerticalStackView)
        self.priceDescriptionHorizontalStackView.addArrangedSubview(self.priceDescriptionSpacer)
        
        self.priceDescriptionVerticalStackView.addArrangedSubview(priceDescriptionTitleHorizontalStackView)
        priceDescriptionTitleHorizontalStackView.addArrangedSubview(priceDescriptionTitleHorizontalSpacer)
        priceDescriptionTitleHorizontalStackView.addArrangedSubview(priceDescriptionTitle)
        
        self.priceDescriptionVerticalStackView.addArrangedSubview(priceDescriptionSubtitleHorizontalStackView)
        self.priceDescriptionSubtitleHorizontalStackView.addArrangedSubview(priceDescriptionSubtitleHorizontalSpacer)
        self.priceDescriptionSubtitleHorizontalStackView.addArrangedSubview(priceDescriptionSubtitle)
        
        self.mainHorizontalStackView.addArrangedSubview(baseRightPadding)
        self.mainContainerView.addSubview(bestOfferBadgeView)
        self.mainContainerView.addSubview(bestOfferBadgeLabel)
        
        selectedDotImageView.tintColor = model?.isLightMode ?? true ?
        UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1.0) :
        UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1.0)
        
        productDescriptionTitle.textColor = model?.textColor ?? .black
        productDescriptionSubtitle.textColor = model?.textColor ?? .black
        priceDescriptionTitle.textColor = model?.textColor ?? .black
        priceDescriptionSubtitle.textColor = model?.textColor ?? .black
        
        self.priceDescriptionTitle.setContentHuggingPriority(.required, for: .horizontal)
        self.priceDescriptionSubtitle.setContentHuggingPriority(.required, for: .horizontal)
        self.productDescriptionTitle.setContentHuggingPriority(.required, for: .horizontal)
        self.productDescriptionTitle.setContentHuggingPriority(.required, for: .horizontal)
        self.priceDescriptionTitle.setContentCompressionResistancePriority(.required, for: .vertical)
        self.productDescriptionTitle.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            mainContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            mainVerticalStackView.topAnchor.constraint(equalTo: mainContainerView.topAnchor, constant: 4),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor),
            mainVerticalStackView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),
            
            self.selectedDotHorizontalStackView.widthAnchor.constraint(equalToConstant: 13),
            self.selectedDotImageView.heightAnchor.constraint(equalToConstant: 13),
            
            baseTopPadding.heightAnchor.constraint(equalToConstant: 9),
            baseBottomPadding.heightAnchor.constraint(equalToConstant: 8),
            baseLeftPadding.widthAnchor.constraint(equalToConstant: 20),
            baseRightPadding.widthAnchor.constraint(equalToConstant: 20),
            
            selectedDotProductDescriptionPadding.widthAnchor.constraint(equalToConstant: 8),
            
            bestOfferBadgeView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: -1),
            bestOfferBadgeView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            bestOfferBadgeView.widthAnchor.constraint(equalToConstant: 115),
            bestOfferBadgeView.heightAnchor.constraint(equalToConstant: 19),
            bestOfferBadgeLabel.centerYAnchor.constraint(equalTo: bestOfferBadgeView.centerYAnchor),
            bestOfferBadgeLabel.leadingAnchor.constraint(equalTo: bestOfferBadgeView.leadingAnchor, constant: 4),
            bestOfferBadgeLabel.trailingAnchor.constraint(equalTo: bestOfferBadgeView.trailingAnchor, constant: -4),
            productDescriptionSubtitleIcon.widthAnchor.constraint(equalToConstant: 16)
        ])
        
        productDescriptionSubtitle.setContentCompressionResistancePriority(.required, for: .horizontal)
        productDescriptionTitle.setContentCompressionResistancePriority(.required, for: .horizontal)

    }
    
    func configure(
        with model: VxMainSubscriptionDataSourceModel,
        tintColor: UIColor = UIColor(red: 20/255, green: 140/255, blue: 190/255, alpha: 1.0),
        paywallType: VxMainPaywallTypes = .v1
    ) {
        self.model = model
        guard let font = model.font else { return }
        configureCommon(with: model, type: paywallType, font: font)
        
        switch paywallType {
        case .v1:
            configureV1(with: model)
        case .v2:
            configureV2(with: model)
        }
    }
    
    private func configureCommon(with model: VxMainSubscriptionDataSourceModel, type: VxMainPaywallTypes, font: VxFont) {
        productDescriptionTitle.text = model.title
        productDescriptionSubtitle.text = model.description
        priceDescriptionTitle.text = model.localizedPrice
        priceDescriptionSubtitle.text = model.monthlyPrice
        
        self.bestOfferBadgeView.isHidden = !model.isBestOffer
        self.bestOfferBadgeLabel.isHidden = !model.isBestOffer
        self.bestOfferBadgeLabel.setFont(font, size: 10, weight: .semibold)
        
        self.productDescriptionTitle.text = generateProductDescriptionTitle(for: type)
        self.productDescriptionTitle.setFont(font, size: 14, weight: .medium)
        
        self.productDescriptionSubtitle.setFont(font, size: 12, weight: .regular)
        self.productDescriptionSubtitle.attributedText = generateProductSubDescription(for: type)
        self.priceDescriptionTitle.setFont(font, size: 14, weight: .bold)
        self.priceDescriptionTitle.attributedText = generatePriceDescriptionTitle(for: type)
        
        self.priceDescriptionSubtitle.text = generatePriceDescriptionSubtitle(for: type)
        self.priceDescriptionSubtitle.isHidden = false
        
        productDescriptionTitle.textColor = model.textColor
        productDescriptionSubtitle.textColor = model.textColor
        priceDescriptionTitle.textColor = model.textColor
        priceDescriptionSubtitle.textColor = model.textColor
        
        selectedDotImageView.tintColor = model.isLightMode ?
        UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1.0) :
        UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1.0)
    }
    
    private func configureV1(with model: VxMainSubscriptionDataSourceModel) {
        self.productDescriptionSubtitleHorizontalStackView.isHidden = (model.eligibleForFreeTrialOrDiscount ?? false)
        let borderColor: UIColor = model.isSelected ? selectedBorderLineColor : unselectedBorderLineColor
        mainVerticalStackView.layer.borderColor = borderColor.cgColor
        
        selectedDotImageView.image = model.isSelected ?
            UIImage(named: "subscription-selected-checkmark", in: .module, compatibleWith: nil) :
            UIImage(systemName: "circle.fill")
    }
    
    private func configureV2(with model: VxMainSubscriptionDataSourceModel) {
        guard let font = model.font else { return }
        let borderColor: UIColor = model.isSelected ? UIColor.colorConverter("BE0DA7") : unselectedBorderLineColor
        mainVerticalStackView.layer.borderColor = borderColor.cgColor
        bestOfferBadgeView.image = UIImage(named: "best-offer-badge-v2", in: .module, compatibleWith: nil)
        selectedDotImageView.image = model.isSelected ?
            UIImage(named: "subscription-selected-checkmark-v2", in: .module, compatibleWith: nil) :
            UIImage(systemName: "circle")
        productDescriptionSubtitleIcon.isHidden = false
        if let initialBonus = model.initialBonus,
           initialBonus != 0 {
            productDescriptionSubtitleHorizontalStackView.isHidden = false
            if model.index == 0 {
                productDescriptionSubtitle.text = VxLocalizables.Subscription.priceTitleWithInitialBonus1.replaceKeyReplacing(toBeReplaced: String(initialBonus))
            }else{
                productDescriptionSubtitle.text = VxLocalizables.Subscription.priceTitleWithInitialBonus2.replaceKeyReplacing(toBeReplaced: String(initialBonus))
            }
        }else{
            productDescriptionSubtitleHorizontalStackView.isHidden = true
        }
        productDescriptionSubtitle.setFont(font, size: 14, weight: .semibold)
    }
    
    private func generateProductDescriptionTitle(for type: VxMainPaywallTypes = .v1) -> String? {
        guard let model else { return nil }
        if type == .v1 {
            if model.eligibleForFreeTrialOrDiscount ?? false {
                return model.subPeriod?.optionText.replacingOccurrences(of: "{xxxfreeTrial}", with: String(model.freeTrialUnit ?? 0)) ?? ""
            } else {
                return VxLocalizables.Subscription.noteligibleOption2
                    .replacingOccurrences(of: "{xxxsubPeriod}", with: model.subPeriod?.periodString ?? "")
            }
        }else{
            if model.index == 0 {
                return VxLocalizables.Subscription.noteligibleOption1
                    .replacingOccurrences(of: "{xxxsubPeriod}", with: model.subPeriod?.periodString ?? "")
            }else{
                return VxLocalizables.Subscription.noteligibleOption2
                    .replacingOccurrences(of: "{xxxsubPeriod}", with: model.subPeriod?.periodString ?? "")
            }
        }
    }
    
    private func generateProductSubDescription(for type: VxMainPaywallTypes = .v1) -> NSAttributedString? {
        guard let data = model else { return nil }
        
        if type == .v1 {
            let baseString = VxLocalizables.Subscription.subscriptionFirstIndexSubDescrtiption
            let localizedPrice = data.localizedPrice ?? ""
            let localizedPeriod = data.subPeriod?.periodText ?? ""
            
            let attributedString = NSMutableAttributedString(string: baseString)
            
            let priceRange = (baseString as NSString).range(of: "{xxxPrice}")
            let periodRange = (baseString as NSString).range(of: "{xxxPeriod}")
            
            if priceRange.location != NSNotFound {
                attributedString.replaceCharacters(in: priceRange, with: localizedPrice)
                attributedString.addAttributes([
                    .font: UIFont.custom(data.font ?? .custom("SF Pro Rounded"), size: 14, weight: .bold)
                ], range: NSRange(location: priceRange.location, length: localizedPrice.count))
            }
            
            if periodRange.location != NSNotFound {
                let updatedLocation = periodRange.location + (localizedPrice.count - priceRange.length)
                let updatedRange = NSRange(location: updatedLocation, length: periodRange.length)
                
                attributedString.replaceCharacters(in: updatedRange, with: localizedPeriod)
                attributedString.addAttributes([
                    .font: UIFont.custom(data.font ?? .custom("SF Pro Rounded"), size: 12, weight: .regular)
                ], range: NSRange(location: updatedRange.location, length: localizedPeriod.count))
            }
            return attributedString
        }else{
            return NSAttributedString(
                string: VxLocalizables.Subscription.subscriptionFirstIndexSubDescrtiption.localize(),
                attributes: [
                    .font: UIFont.custom(data.font ?? .custom("SF Pro Rounded"), size: 14, weight: .semibold)
                ]
            )
        }
    }
    
    func generatePriceDescriptionTitle(for type: VxMainPaywallTypes = .v1) -> NSAttributedString? {
        guard let model else { return nil }
        
        if type == .v1 {
            if (model.eligibleForFreeTrialOrDiscount) == false {
                let priceString = switch model.comparedPeriod {
                case .day: model.dailyPrice
                case .week: model.weeklyPrice
                case .month: model.monthlyPrice
                case .year, _: model.localizedPrice
                }
                return NSAttributedString(string: priceString ?? "")
            } else {
                let result = NSMutableAttributedString()
                
                let periodLabel = NSAttributedString(
                    string: model.subPeriod?.thenPeriodlyLabel ?? "",
                    attributes: [.font: UIFont.custom(model.font ?? .system("SF Pro Rounded"), size: 12, weight: .regular)]
                )
                result.append(periodLabel)
                
                let priceLabel = NSAttributedString(
                    string: model.localizedPrice ?? "",
                    attributes: [.font: UIFont.custom(model.font ?? .system("SF Pro Rounded"), size:14, weight: .bold)]
                )
                result.append(priceLabel)
                
                return result
            }
        } else {
            let result = NSMutableAttributedString()
            
            let priceLabel = NSAttributedString(
                string: model.localizedPrice ?? "",
                attributes: [
                    .font: UIFont.custom(model.font ?? .system("SF Pro Rounded"), size: 12, weight: .bold)
                ]
            )
            result.append(priceLabel)
            
            let periodLabel = NSAttributedString(
                string: " / \(model.subPeriod?.singlePeriodString ?? "")",
                attributes: [
                    .font: UIFont.custom(model.font ?? .system("SF Pro Rounded"), size: 12, weight: .regular)
                ]
            )
            result.append(periodLabel)
            
            return result
        }
    }
    
    func generatePriceDescriptionSubtitle(for type: VxMainPaywallTypes = .v1) -> String? {
        guard let model else { return nil }
        guard let font = model.font else { return nil }
        if type == .v1 {
            self.priceDescriptionSubtitle.setFont(font, size: 12, weight: .regular)
            self.priceDescriptionSubtitleHorizontalStackView.isHidden = false
            if let comparedPeriod = model.comparedPeriod {
                return comparedPeriod.periodText
            }else{
                return model.subPeriod?.periodText
            }
        }else{
            self.priceDescriptionSubtitle.setFont(font, size: 10, weight: .regular)
            if let weeklyPrice = model.weeklyPrice,
               (model.subPeriod == .month || model.subPeriod == .year) {
                self.priceDescriptionSubtitleHorizontalStackView.isHidden = false
                return "(\(weeklyPrice) / \(VxLocalizables.Subscription.singlePeriodWeekText))"
            }else{
                self.priceDescriptionSubtitleHorizontalStackView.isHidden = true
                return ""
            }
        }
    }
}

