//
//  TicketDetailRootView.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 7.02.2025.
//

import UIKit
import Combine

final public class TicketDetailRootView: VxNiblessView {
    private let viewModel: VxSupportViewModel
    private var disposeBag = Set<AnyCancellable>()
    private let category: String?
    
    private var messageInputBottomConstraint: NSLayoutConstraint?
    private var dividerBottomConstraint: NSLayoutConstraint?
    private var newChatStackTopConstraint: NSLayoutConstraint?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = viewModel.configuration.backgroundColor
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
        label.text = VxLocalizables.Support.helpTitleLabel
        label.setFont(viewModel.configuration.font, size: 16, weight: .semibold)
        label.textColor = viewModel.configuration.detailHelpColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var chatTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .interactive
        return tableView
    }()
    
    private lazy var messageInputStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        textField.placeholder = VxLocalizables.Support.textFieldPlaceholder
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
    
    private lazy var dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorConverter("131313")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = viewModel.configuration.navigationTintColor
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    public init(frame: CGRect = .zero, viewModel: VxSupportViewModel, category: String? = nil) {
        self.viewModel = viewModel
        self.category = category
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        subscribe()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(containerView)
        
        containerView.addSubview(newChatStackView)
        containerView.addSubview(chatTableView)
        containerView.addSubview(messageInputStack)
        containerView.addSubview(dividerLineView)
        containerView.addSubview(loadingIndicator)
        
        newChatStackView.addArrangedSubview(helpImageView)
        newChatStackView.addArrangedSubview(helpTitleLabel)
        
        messageInputStack.addArrangedSubview(addButton)
        messageInputStack.addArrangedSubview(messageTextField)
        messageInputStack.addArrangedSubview(sendButton)
        
        setupKeyboardHandling()
        setupGestures()
        setupTextFieldAndButtons()
        updateViewState()
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
            
            loadingIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            newChatStackTopConstraint!,
            newChatStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            chatTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: dividerLineView.topAnchor),
            
            messageInputStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            messageInputStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            messageInputBottomConstraint!,
            
            dividerLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerLineView.heightAnchor.constraint(equalToConstant: 1),
            dividerBottomConstraint!,
            
            messageTextField.heightAnchor.constraint(equalToConstant: 43),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.heightAnchor.constraint(equalToConstant: 24),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func setupGestures() {
        let containerTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        containerView.addGestureRecognizer(containerTapGesture)
    }
    
    private func setupTextFieldAndButtons() {
        messageTextField.returnKeyType = .send
        messageTextField.delegate = self
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        addButton.isHidden = true
    }
    
    private func subscribe() {
        viewModel.loadingStateTicketMessagesPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.containerView.isUserInteractionEnabled = !isLoading
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &disposeBag)
        
        viewModel.$ticketMessages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                guard let self = self else { return }
                self.chatTableView.reloadData()
                
                if let count = messages?.messages.count,
                   count > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
            }
            .store(in: &disposeBag)
        
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        messageInputBottomConstraint?.constant = -keyboardFrame.height + (UIScreen.main.bounds.height > 667 ? 20 : 0)
        newChatStackTopConstraint?.constant = 100
        
        messageTextField.textColor = .white
        messageTextField.tintColor = .white
        sendButton.setImage(viewModel.configuration.detailSendButtonActiveImage, for: .normal)
        
        layoutIfNeeded()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        messageInputBottomConstraint?.constant = -20
        newChatStackTopConstraint?.constant = 200
        
        messageTextField.backgroundColor = viewModel.configuration.messageTextFieldBackgroundColor
        sendButton.setImage(viewModel.configuration.detailSendButtonPassiveImage, for: .normal)
        
        layoutIfNeeded()
    }
    
    @objc private func dismissKeyboard() {
        messageTextField.resignFirstResponder()
        messageTextField.backgroundColor = viewModel.configuration.messageTextFieldBackgroundColor
        sendButton.setImage(viewModel.configuration.detailSendButtonPassiveImage, for: .normal)
    }
    
    @objc private func sendButtonTapped() {
        guard let message = messageTextField.text,
              !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        sendButton.isEnabled = false
        
        if viewModel.isNewTicket {
            guard let category = category else { return }
            self.messageTextField.text = ""
            self.viewModel.isNewTicket = false
            self.updateViewState()
            
            viewModel.createNewTicket(category: category, message: trimmedMessage) { [weak self] success in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.sendButton.isEnabled = true
                    if success {
                        let isKeyboardActive = self.messageTextField.isFirstResponder
                        if let newTicketId = self.viewModel.currentTicket?.id {
                            self.viewModel.getTicketMessagesById(ticketId: newTicketId) { _ in }
                        }
                    } else {
                        self.viewModel.isNewTicket = true
                        self.updateViewState()
                    }
                }
            }
        } else if let ticket = viewModel.ticketMessages {
            self.messageTextField.text = ""
            viewModel.createNewMessage(ticketId: ticket.id, message: trimmedMessage) { [weak self] success in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.sendButton.isEnabled = true
                    if !success {
                        self.messageTextField.text = trimmedMessage
                    }
                }
            }
        }
    }
    
    func updateViewState() {
        let isNew = viewModel.isNewTicket
        newChatStackView.isHidden = !isNew
        chatTableView.isHidden = isNew
        if isNew {
            messageTextField.becomeFirstResponder()
        }
        chatTableView.backgroundColor = .clear
        messageTextField.backgroundColor = viewModel.configuration.messageTextFieldBackgroundColor
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TicketDetailRootView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.ticketMessages?.messages.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.identifier, for: indexPath) as? ChatMessageCell,
              let messages = viewModel.ticketMessages?.messages else {
            return UITableViewCell()
        }
        
        let message = messages[indexPath.row]
        cell.configure(with: message, configuration: viewModel.configuration)
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
}

extension TicketDetailRootView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped()
        return false
    }
}
