//
//  TicketListCell.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 5.02.2025.
//

import UIKit

final class TicketListCell: UITableViewCell {
    static let identifier = "ChatListCell"
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    private lazy var leftContentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var unreadIndicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var titleLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: VxLabel = {
        let label = VxLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(mainStackView)
        contentView.addSubview(separatorView)
        
        leftContentStack.addArrangedSubview(unreadIndicatorView)
        leftContentStack.addArrangedSubview(contentStackView)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        
        mainStackView.addArrangedSubview(leftContentStack)
        mainStackView.addArrangedSubview(dateLabel)
        
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            unreadIndicatorView.widthAnchor.constraint(equalToConstant: 8),
            unreadIndicatorView.heightAnchor.constraint(equalToConstant: 8),
            unreadIndicatorView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 8),
            unreadIndicatorView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            dateLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
    }
    
    func configure(with ticket: VxGetTicketsResponse, configuration: VxSupportConfiguration) {
        titleLabel.text = ticket.category
        titleLabel.textColor = configuration.listingItemTitleColor
        titleLabel.setFont(configuration.font, size: 14, weight: .semibold)
        
        descriptionLabel.text = ticket.lastMessage
        descriptionLabel.textColor = configuration.listingDescriptionColor
        descriptionLabel.setFont(configuration.font, size: 12, weight: .regular)

        dateLabel.text =  ticket.lastMessageCreatedAt?.formattedDateForList()
        dateLabel.textColor = configuration.listingDateColor
        dateLabel.setFont(configuration.font, size: 10, weight: .medium)
        
        unreadIndicatorView.backgroundColor = configuration.listingUnreadColor
        unreadIndicatorView.isHidden = ticket.isSeen ?? false
    }
}
