//
//  VxSupportRootView.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 4.02.2025.
//

import UIKit
import Combine

enum ContactUsState {
    case emptyTicket
    case chatList
    case newChat
    case chatScreen
}

final public class VxSupportRootView: VxNiblessView {
    private let viewModel: VxSupportViewModel
    private var disposeBag = Set<AnyCancellable>()
    
    private var currentState: ContactUsState = .emptyTicket {
        didSet {
            updateUI()
            statePublisher.send(currentState)
        }
    }
    
    let statePublisher = CurrentValueSubject<ContactUsState, Never>(.emptyTicket)
    
    private var selectedCategory: String?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = viewModel.configuration.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emptyChatStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var emptyChatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "empty_message_write_icon", in: .module, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyChatTitleLabel: VxLabel = {
        let label = VxLabel()
        label.text = "Lorem ipsum dolor sit amet"
        label.setFont(viewModel.configuration.font, size: 14, weight: .medium)
        label.textColor = viewModel.configuration.listingDescriptionColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var newChatButton: VxButton = {
        let button = VxButton(font: viewModel.configuration.font,
                             fontSize: 14,
                             weight: .bold)
        button.configure(backgroundColor: viewModel.configuration.listingActionColor,
                        foregroundColor: viewModel.configuration.listingActionTextColor,
                        cornerRadius: 8)
        button.setTitle("New Chat", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(newChatButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func newChatButtonTapped() {
        showTicketBottomSheet()
    }

    private lazy var chatListTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatListCell.self, forCellReuseIdentifier: ChatListCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = .zero
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
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
        textField.backgroundColor = UIColor.colorConverter("0E0E0E")
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
        button.setImage(UIImage(named: "message_button_icon", in: .module, compatibleWith: nil), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorConverter("131313")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var chatTableView: UITableView = {
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

//     //Mock messages
//    private var chatMessages: [ChatMessage] = [
//        ChatMessage(text: "Chat Introduction and Greetings", date: "09:41", isFromUser: false, isSubject: true),
//        ChatMessage(text: "Lorem ipsum dolor sit amet", date: "09:42", isFromUser: true, isSubject: false)
//    ]

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = viewModel.configuration.navigationTintColor
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private var bottomSheetView: TicketsBottomSheetView?
    private var dimmedView: UIView?

    private var messageInputBottomConstraint: NSLayoutConstraint?
    private var dividerBottomConstraint: NSLayoutConstraint?
    private var chatTableBottomConstraint: NSLayoutConstraint?

    public init(frame: CGRect = .zero, viewModel: VxSupportViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(containerView)
        addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        observeLoadingState()
        updateUI()
    }
    
    private func updateUI() {
        // Remove all subviews first
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        switch currentState {
        case .emptyTicket:
            setupEmptyChatUI()
        case .chatList:
            setupChatListUI()
        case .newChat:
            setupNewChatUI()
        case .chatScreen:
            setupChatScreenUI()
        }
    }
    
    private func setupEmptyChatUI() {
        containerView.addSubview(emptyChatStackView)
        emptyChatStackView.addArrangedSubview(emptyChatImageView)
        emptyChatStackView.addArrangedSubview(emptyChatTitleLabel)
        containerView.addSubview(newChatButton)
        
        NSLayoutConstraint.activate([
            emptyChatStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 104),
            emptyChatStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            emptyChatStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            emptyChatImageView.widthAnchor.constraint(equalToConstant: 64),
            emptyChatImageView.heightAnchor.constraint(equalToConstant: 64),
            
            newChatButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            newChatButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            newChatButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -11),
            newChatButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setupChatListUI() {
        containerView.addSubview(chatListTableView)
        
        NSLayoutConstraint.activate([
            chatListTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            chatListTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            chatListTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            chatListTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNewChatUI() {
        containerView.addSubview(newChatStackView)
        containerView.addSubview(messageInputStack)
        containerView.addSubview(dividerLineView)
        
        newChatStackView.addArrangedSubview(helpImageView)
        newChatStackView.addArrangedSubview(helpTitleLabel)
        
        messageInputStack.addArrangedSubview(addButton)
        messageInputStack.addArrangedSubview(messageTextField)
        messageInputStack.addArrangedSubview(sendButton)
        
        // Constraint'leri saklayacağımız değişkenleri oluşturalım
        messageInputBottomConstraint = messageInputStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        dividerBottomConstraint = dividerLineView.bottomAnchor.constraint(equalTo: messageInputStack.topAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            // Top Stack Constraints - top değerini azalttık
            newChatStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
            newChatStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // Divider Constraints
            dividerLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerLineView.heightAnchor.constraint(equalToConstant: 1),
            dividerBottomConstraint!,
            
            // Message Input Stack Constraints
            messageInputStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            messageInputStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            messageInputBottomConstraint!,
            
            messageTextField.heightAnchor.constraint(equalToConstant: 43),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.heightAnchor.constraint(equalToConstant: 24),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Keyboard ve input ayarları
        messageTextField.becomeFirstResponder()
        messageTextField.returnKeyType = .done
        messageTextField.delegate = self
        
        // Keyboard notifications
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillShow),
                                             name: UIResponder.keyboardWillShowNotification,
                                             object: nil)
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillHide),
                                             name: UIResponder.keyboardWillHideNotification,
                                             object: nil)
        
        // Dismiss keyboard gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        containerView.addGestureRecognizer(tapGesture)
        
        // Send button action
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    private func setupChatScreenUI() {
        containerView.addSubview(chatTableView)
        containerView.addSubview(messageInputStack)
        containerView.addSubview(dividerLineView)
        
        messageInputStack.addArrangedSubview(addButton)
        messageInputStack.addArrangedSubview(messageTextField)
        messageInputStack.addArrangedSubview(sendButton)

        messageTextField.textColor = .white
        messageTextField.tintColor = .white
        sendButton.setImage(UIImage(named: "send_message_button_icon", in: .module, compatibleWith: nil), for: .normal)
        
//        // Initial messages'ı ayarla
//        if let ticket = viewModel.currentTicket {
//            chatMessages = [
//                ChatMessage(
//                    text: ticket.category,
//                    date: ticket.createdAt,
//                    isFromUser: false,
//                    isSubject: true
//                )
//            ]
//        }
        
        // Constraint'leri saklayacağımız değişkenleri oluşturalım
        messageInputBottomConstraint = messageInputStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        dividerBottomConstraint = dividerLineView.bottomAnchor.constraint(equalTo: messageInputStack.topAnchor, constant: -16)
        chatTableBottomConstraint = chatTableView.bottomAnchor.constraint(equalTo: dividerLineView.topAnchor)
        
        NSLayoutConstraint.activate([
            chatTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chatTableBottomConstraint!,
            
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

        messageTextField.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillShow),
                                             name: UIResponder.keyboardWillShowNotification,
                                             object: nil)
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillHide),
                                             name: UIResponder.keyboardWillHideNotification,
                                             object: nil)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        chatTableView.addGestureRecognizer(tapGesture)
        
        messageTextField.returnKeyType = .done
        messageTextField.delegate = self
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        messageInputBottomConstraint?.constant = -keyboardFrame.height + 20
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        messageInputBottomConstraint?.constant = -20
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    @objc private func dismissKeyboard() {
        messageTextField.resignFirstResponder()
    }

    private func observeLoadingState() {
        viewModel.loadingStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.containerView.isUserInteractionEnabled = !isLoading
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                    self?.currentState = self?.viewModel.tickets.isEmpty == true ? .emptyTicket : .chatList
                }
            }
            .store(in: &disposeBag)
    }

    func showTicketBottomSheet() {
        guard !viewModel.isBottomSheetPresented else { return }
        viewModel.isBottomSheetPresented = true
        let dimmedView = UIView()
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmedView.alpha = 0
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        self.dimmedView = dimmedView
        
        let bottomSheet = TicketsBottomSheetView(
            configuration: viewModel.configuration,
            onTicketSelected: { [weak self] category in
                self?.handleTicketSelection(category)
            }
        )
        bottomSheet.translatesAutoresizingMaskIntoConstraints = false
        self.bottomSheetView = bottomSheet
        
        addSubview(dimmedView)
        addSubview(bottomSheet)
        
        let bottomSheetHeight = UIScreen.main.bounds.height * 0.4
        
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            bottomSheet.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSheet.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSheet.heightAnchor.constraint(equalToConstant: bottomSheetHeight),
            bottomSheet.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        bottomSheet.transform = CGAffineTransform(translationX: 0, y: bottomSheetHeight)
        
        UIView.animate(withDuration: 0.3) {
            self.dimmedView?.alpha = 1
            bottomSheet.transform = .identity
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissBottomSheet))
        dimmedView.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissBottomSheet() {
        guard let bottomSheet = bottomSheetView else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dimmedView?.alpha = 0
            bottomSheet.transform = CGAffineTransform(translationX: 0, y: bottomSheet.frame.height)
        }) { _ in
            self.dimmedView?.removeFromSuperview()
            self.bottomSheetView?.removeFromSuperview()
            self.dimmedView = nil
            self.bottomSheetView = nil
            self.viewModel.isBottomSheetPresented = false
        }
    }

    private func handleTicketSelection(_ category: String) {
        dismissBottomSheet()
        selectedCategory = category
        currentState = .newChat
    }

    @objc private func sendButtonTapped() {
        guard let category = selectedCategory,
              let message = messageTextField.text,
              !message.isEmpty else { return }
        
        // Servis çağrısı yapılacak
        viewModel.createNewTicket(category: category, message: message) { [weak self] success in
            guard let self = self else { return }
            if success {
                DispatchQueue.main.async {
                    self.messageTextField.text = ""
                    self.currentState = .chatScreen
                }
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension VxSupportRootView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == chatTableView {
            return viewModel.ticketMessages?.messages.count ?? 0
        } else {
            return viewModel.tickets.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == chatTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.identifier, for: indexPath) as? ChatMessageCell else {
                return UITableViewCell()
            }
            
            if let messages = viewModel.ticketMessages?.messages {
                let message = messages[indexPath.row]
                cell.configure(with: message, configuration: viewModel.configuration)
            }
            
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatListCell.identifier, for: indexPath) as? ChatListCell else {
                return UITableViewCell()
            }
            
            let item = viewModel.tickets[indexPath.row]
            cell.configure(with: item, configuration: viewModel.configuration)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Debug: bura yine tetiklencek mi bakalım")
        let item = viewModel.tickets[indexPath.row]
        viewModel.getTicketMessagesById(ticketId: item.id) { [weak self] success in
            guard let self = self else { return }
            if success {
                DispatchQueue.main.async {
                    self.currentState = .chatScreen
                    self.chatTableView.reloadData()
                }
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension VxSupportRootView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
