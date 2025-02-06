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
        backgroundColor = .clear
        contentView.addSubview(messageStackView)
        messageStackView.addArrangedSubview(messageContainerView)
        messageContainerView.addSubview(messageLabel)
        messageContainerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            messageStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            messageStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            messageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            messageStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            messageLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with message: Message, configuration: VxSupportConfiguration) {
        messageLabel.text = message.message
        dateLabel.text = message.createdAt.formattedDate()
        if !message.isFromDevice {
            // Admin mesajı görünümü
            messageContainerView.backgroundColor = configuration.detailSentBackgroundColor
            messageContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            messageContainerView.layer.cornerRadius = 16
            messageLabel.textColor = configuration.detailSentMessageColor
            dateLabel.textColor = configuration.detailSentDateColor
            // Sağ taraf constraint'leri
            messageStackView.alignment = .trailing
        } else {
            // Kullanıcı mesajı görünümü
            messageContainerView.backgroundColor = configuration.detailTicketBorderColor
            messageLabel.textColor = configuration.detailTicketDateColor
            dateLabel.textColor = configuration.detailTicketDateColor
            messageContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            messageContainerView.layer.cornerRadius = 16

            // Sol taraf constraint'leri
            messageStackView.alignment = .leading
        }
        
        messageLabel.setFont(configuration.font, size: 14, weight: .semibold)
        dateLabel.setFont(configuration.font, size: 8, weight: .medium)
    }
} 
