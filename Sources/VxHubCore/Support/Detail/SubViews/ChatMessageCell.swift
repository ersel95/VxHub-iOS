#if canImport(UIKit)
//
//  ChatMessageCell.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 5.02.2025.
//

import UIKit


final class ChatMessageCell: UITableViewCell {
    static let identifier = "ChatMessageCell"
    
    private lazy var messageStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var spacerView1: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var spacerView2: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var messageContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var messageLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: VxLabel = {
        let label = VxLabel()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(messageStackView)
        messageStackView.addArrangedSubview(spacerView1)
        messageStackView.addArrangedSubview(messageContainerView)
        messageStackView.addArrangedSubview(spacerView2)
        messageContainerView.addSubview(messageLabel)
        messageContainerView.addSubview(dateLabel)
    }

    private func setupConstraints() {
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        messageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
            messageStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            messageStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            messageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            messageStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            messageContainerView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.85),

            messageLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -16),

            dateLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -16),
            dateLabel.leadingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 8)
        ])
    }
    
    func configure(with message: Message, configuration: VxSupportConfiguration) {
        messageLabel.text = message.message
        dateLabel.text = message.createdAt.formattedDate()
        
        if !message.isFromDevice {
            messageContainerView.backgroundColor = configuration.detailAdminTicketBackgroundColor
            messageContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            messageContainerView.layer.cornerRadius = 16
            messageContainerView.layer.borderWidth = 1
            messageContainerView.layer.borderColor = configuration.detailAdminTicketBorderColor.cgColor
            messageLabel.textColor = configuration.detailAdminTicketMessageColor
            dateLabel.textColor = configuration.detailAdminTicketDateColor
            messageStackView.alignment = .trailing
            spacerView1.isHidden = true
            spacerView2.isHidden = false
        } else {
            messageContainerView.backgroundColor = configuration.detailUserTicketBackgroundColor
            messageLabel.textColor = configuration.detailUserTicketMessageColor
            dateLabel.textColor = configuration.detailUserTicketDateColor
            messageContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            messageContainerView.layer.cornerRadius = 16
            messageContainerView.layer.borderWidth = 0
            messageContainerView.layer.borderColor = nil
            messageStackView.alignment = .leading
            spacerView1.isHidden = false
            spacerView2.isHidden = true
        }
        messageLabel.setFont(configuration.font, size: 14, weight: .semibold)
        dateLabel.setFont(configuration.font, size: 8, weight: .medium)
        layoutIfNeeded()
    }
}
#endif
