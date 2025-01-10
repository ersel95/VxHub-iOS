//
//  File.swift
//  VxHub
//
//  Created by furkan on 9.01.2025.
//

import UIKit

final class VxMainPaywallTableViewCell: VxNiblessTableViewCell {
    var model: VxMainSubscriptionDataSourceModel?
    
    // MARK: - Base Views
    private lazy var mainContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var mainVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layer.borderColor = UIColor.green.cgColor
        stackView.layer.borderWidth = 1
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
        imageView.tintColor = .red
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

    private lazy var productDescriptionTitle: UILabel = {
        let label = UILabel()
        label.text = "Yearly Accesss"
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(red: 21/255, green: 33/255, blue: 61/255, alpha: 1.0)
        return label
    }()

    private lazy var productDescriptionSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Unlimited Access to All Features"
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(red: 21/255, green: 33/255, blue: 61/255, alpha: 1.0)
        return label
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

    private lazy var priceDescriptionTitle: UILabel = {
        let label = UILabel()
        label.text = "Cheap price"
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(red: 21/255, green: 33/255, blue: 61/255, alpha: 1.0)
        label.textAlignment = .right
        return label
    }()

    private lazy var priceDescriptionSubtitle: UILabel = {
        let label = UILabel()
        label.text = "only 99"
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(red: 21/255, green: 33/255, blue: 61/255, alpha: 1.0)
        label.textAlignment = .right
        return label
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
    
    private lazy var bestOfferBadgeLabel: UILabel = {
        let label = UILabel()
        label.text = "Best Offer"
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
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
        self.productDescriptionVerticalStackView.addArrangedSubview(productDescriptionTitle)
        self.productDescriptionVerticalStackView.addArrangedSubview(productDescriptionSubtitle)
        self.productDescriptionHorizontalStackView.addArrangedSubview(productDescriptionSpacer)

        self.mainHorizontalStackView.addArrangedSubview(descriptionToPriceSpacer)

        self.mainHorizontalStackView.addArrangedSubview(priceDescriptionHorizontalStackView)
        self.priceDescriptionHorizontalStackView.addArrangedSubview(priceDescriptionVerticalStackView)
        self.priceDescriptionHorizontalStackView.addArrangedSubview(self.priceDescriptionSpacer)
        self.priceDescriptionVerticalStackView.addArrangedSubview(priceDescriptionTitle)
        self.priceDescriptionVerticalStackView.addArrangedSubview(priceDescriptionSubtitle)
        
        self.mainHorizontalStackView.addArrangedSubview(baseRightPadding)
        self.mainContainerView.addSubview(bestOfferBadgeView)
        self.mainContainerView.addSubview(bestOfferBadgeLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            mainContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            mainVerticalStackView.topAnchor.constraint(equalTo: mainContainerView.topAnchor, constant: 4),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor),
            mainVerticalStackView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),

            self.selectedDotHorizontalStackView.widthAnchor.constraint(equalToConstant: 13),
            self.selectedDotImageView.heightAnchor.constraint(equalToConstant: 13),

            baseTopPadding.heightAnchor.constraint(equalToConstant: 9),
            baseBottomPadding.heightAnchor.constraint(equalToConstant: 9),
            baseLeftPadding.widthAnchor.constraint(equalToConstant: 20),
            baseRightPadding.widthAnchor.constraint(equalToConstant: 20),
            
            selectedDotProductDescriptionPadding.widthAnchor.constraint(equalToConstant: 8),

            bestOfferBadgeView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: -1),
            bestOfferBadgeView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            bestOfferBadgeView.widthAnchor.constraint(equalToConstant: 115),
            bestOfferBadgeView.heightAnchor.constraint(equalToConstant: 19),
            bestOfferBadgeLabel.centerYAnchor.constraint(equalTo: bestOfferBadgeView.centerYAnchor),
            bestOfferBadgeLabel.leadingAnchor.constraint(equalTo: bestOfferBadgeView.leadingAnchor, constant: 4),
            bestOfferBadgeLabel.trailingAnchor.constraint(equalTo: bestOfferBadgeView.trailingAnchor, constant: -4)
        ])
        self.priceDescriptionTitle.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.priceDescriptionTitle.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    func configure(with model: VxMainSubscriptionDataSourceModel) {
        self.model = model
        productDescriptionTitle.font = .custom(model.baseFont, size: 12)
        productDescriptionSubtitle.font = .custom(model.baseFont, size: 12)
        priceDescriptionTitle.font = .custom(model.baseFont, size: 12)
        priceDescriptionSubtitle.font = .custom(model.baseFont, size: 12)
        bestOfferBadgeLabel.font = .custom(model.baseFont, size: 10)
        
        productDescriptionTitle.text = model.title
        productDescriptionSubtitle.text = model.description
        priceDescriptionTitle.text = model.localizedPrice
        priceDescriptionSubtitle.text = model.monthlyPrice
        
        let color: UIColor = model.isSelected ? .systemBlue : .gray
        mainVerticalStackView.layer.borderColor = color.cgColor
        selectedDotImageView.tintColor = color
        
        self.bestOfferBadgeView.isHidden = !model.isBestOffer
        self.bestOfferBadgeLabel.isHidden = !model.isBestOffer
        
        self.productDescriptionSubtitle.isHidden = (model.eligibleForFreeTrialOrDiscount ?? false)
        
        self.productDescriptionTitle.text = generateProductDescriptionTitle()
        self.productDescriptionSubtitle.attributedText = generateProductSubDescription()
        
        self.priceDescriptionTitle.attributedText = generatePriceDescriptionTitle()
        self.priceDescriptionSubtitle.text = generatePriceDescriptionSubtitle()
        
        
    }
    
    private func generateProductDescriptionTitle() -> String? {
        guard let model else { return nil }
        if model.eligibleForFreeTrialOrDiscount ?? false {
            return model.subPeriod?.optionText.replacingOccurrences(of: "{xxxfreeTrial}", with: String(model.freeTrialUnit ?? 0)) ?? ""
        } else {
            return VxLocalizables.Subscription.noteligibleOption2
                .replacingOccurrences(of: "{xxxsubPeriod}", with: model.subPeriod?.periodString ?? "")
        }
    } 
    
    private func generateProductSubDescription() -> NSAttributedString? {
        guard let data = model else { return nil }
        
        let baseString = VxLocalizables.Subscription.subscriptionFirstIndexSubDescrtiption
        let localizedPrice = data.localizedPrice ?? ""
        let localizedPeriod = data.subPeriod?.periodText ?? ""
        
        let attributedString = NSMutableAttributedString(string: baseString)
        
        let priceRange = (baseString as NSString).range(of: "{xxxPrice}")
        let periodRange = (baseString as NSString).range(of: "{xxxPeriod}")
        
        if priceRange.location != NSNotFound {
            attributedString.replaceCharacters(in: priceRange, with: localizedPrice)
            attributedString.addAttributes([
                .font: UIFont.custom(data.baseFont, size: 14, weight: .medium)
            ], range: NSRange(location: priceRange.location, length: localizedPrice.count))
        }
        
        if periodRange.location != NSNotFound {
            let updatedLocation = periodRange.location + (localizedPrice.count - priceRange.length)
            let updatedRange = NSRange(location: updatedLocation, length: periodRange.length)
            
            attributedString.replaceCharacters(in: updatedRange, with: localizedPeriod)
            attributedString.addAttributes([
                .font: UIFont.custom(data.baseFont, size: 12, weight: .regular)
            ], range: NSRange(location: updatedRange.location, length: localizedPeriod.count))
        }
        
        return attributedString
    }

    
    func generatePriceDescriptionTitle() -> NSAttributedString? {
        guard let model else { return nil }
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
                attributes: [.font: UIFont.custom(model.baseFont, size: 12, weight: .regular)]
            )
            result.append(periodLabel)
            
            let priceLabel = NSAttributedString(
                string: model.localizedPrice ?? "",
                attributes: [.font: UIFont.custom(model.baseFont, size:14, weight: .semibold)]
            )
            result.append(priceLabel)
            
            return result
        }
    }
    
    func generatePriceDescriptionSubtitle() -> String? {
        guard let model else { return nil }
        if let comparedPeriod = model.comparedPeriod {
            return comparedPeriod.periodText
        }else{
            return model.subPeriod?.periodText
        }
    }
}
