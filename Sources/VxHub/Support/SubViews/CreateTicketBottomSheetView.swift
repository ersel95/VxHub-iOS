//
//  CreateTicketBottomSheetView.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 7.02.2025.
//

import UIKit
import Combine

extension Notification.Name {
    static let ticketCreated = Notification.Name("ticketCreated")
}

final class CreateTicketBottomSheetView: UIView {
    private let viewModel: VxSupportViewModel
    private var selectedCategory: String
    private var onDismiss: (() -> Void)?

    private var messageInputBottomConstraint: NSLayoutConstraint?
    private var dividerBottomConstraint: NSLayoutConstraint?
    private var newChatStackTopConstraint: NSLayoutConstraint?

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var newChatStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var helpImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "empty_messages_help_icon", in: .module, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var helpTitleLabel: VxLabel = {
        let label = VxLabel()
        label.text = "How can i help you ?"
        label.setFont(viewModel.configuration.font, size: 16, weight: .semibold)
        label.textColor = viewModel.configuration.detailHelpColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var messageInputStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorConverter("131313")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var addButton: VxButton = {
        let button = VxButton(font: viewModel.configuration.font,
                             fontSize: 14,
                             weight: .regular)
        button.setImage(UIImage(named: "plus_icon", in: .module, compatibleWith: nil), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var messageTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = viewModel.configuration.messageTextFieldBackgroundColor
        
        textField.placeholder = "Write your messsage here"
        textField.font = .custom(viewModel.configuration.font, size: 14, weight: .regular)
        textField.textColor = viewModel.configuration.detailPlaceholderColor
        textField.layer.cornerRadius = 20
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setImage(viewModel.configuration.detailSendButtonPassiveImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: VxSupportViewModel, selectedCategory: String, onDismiss: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.selectedCategory = selectedCategory
        self.onDismiss = onDismiss
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = viewModel.configuration.backgroundColor
        addSubview(containerView)
        
        containerView.addSubview(newChatStackView)
        containerView.addSubview(messageInputStack)
        containerView.addSubview(dividerLineView)
        
        newChatStackView.addArrangedSubview(helpImageView)
        newChatStackView.addArrangedSubview(helpTitleLabel)
        
        messageInputStack.addArrangedSubview(addButton)
        messageInputStack.addArrangedSubview(messageTextField)
        messageInputStack.addArrangedSubview(sendButton)

        
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        messageInputBottomConstraint = messageInputStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        dividerBottomConstraint = dividerLineView.bottomAnchor.constraint(equalTo: messageInputStack.topAnchor, constant: -16)
        newChatStackTopConstraint = newChatStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 200)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            newChatStackTopConstraint!,
            newChatStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            dividerLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerLineView.heightAnchor.constraint(equalToConstant: 1),
            dividerBottomConstraint!,
            
            messageInputStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            messageInputStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            messageInputBottomConstraint!,
            
            messageTextField.heightAnchor.constraint(equalToConstant: 43),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.heightAnchor.constraint(equalToConstant: 24),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        messageTextField.becomeFirstResponder()
        messageTextField.returnKeyType = .done
        messageTextField.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillShow),
                                             name: UIResponder.keyboardWillShowNotification,
                                             object: nil)
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillHide),
                                             name: UIResponder.keyboardWillHideNotification,
                                             object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        containerView.addGestureRecognizer(tapGesture)
        
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        messageInputBottomConstraint?.constant = -keyboardFrame.height + (UIScreen.main.bounds.height > 667 ? 20 : 0)
        newChatStackTopConstraint?.constant = 100
        
        messageTextField.textColor = .white
        messageTextField.tintColor = .white
        sendButton.setImage(viewModel.configuration.detailSendButtonActiveImage, for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        messageInputBottomConstraint?.constant = -20
        newChatStackTopConstraint?.constant = 200
        
        messageTextField.backgroundColor = viewModel.configuration.messageTextFieldBackgroundColor
        sendButton.setImage(viewModel.configuration.detailSendButtonPassiveImage, for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    @objc private func dismissKeyboard() {
        messageTextField.resignFirstResponder()
        messageTextField.backgroundColor = viewModel.configuration.messageTextFieldBackgroundColor
        sendButton.setImage(viewModel.configuration.detailSendButtonPassiveImage, for: .normal)
    }
    
    @objc private func sendButtonTapped() {
        guard let message = messageTextField.text,
              !message.isEmpty else { return }
        
        sendButton.isEnabled = false
        messageTextField.isEnabled = false
        
        viewModel.createNewTicket(category: selectedCategory, message: message) { [weak self] success in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.sendButton.isEnabled = true
                self.messageTextField.isEnabled = true
                if success {
                    NotificationCenter.default.post(name: .ticketCreated, object: nil)
                    self.onDismiss?()
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CreateTicketBottomSheetView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
