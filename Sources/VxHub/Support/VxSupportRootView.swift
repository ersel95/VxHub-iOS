//
//  VxSupportRootView.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 4.02.2025.
//

import UIKit

protocol VxSupportRootViewDelegate: AnyObject {
    func didCreateTicket()
}

final public class VxSupportRootView: VxNiblessView {
    private let viewModel: VxSupportViewModel
    weak var delegate: VxSupportRootViewDelegate?
    private var ticketsBottomSheetView: TicketsBottomSheetView?
    private var dimmedView: UIView?
    
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

    public init(frame: CGRect = .zero, viewModel: VxSupportViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(emptyChatStackView)
        emptyChatStackView.addArrangedSubview(emptyChatImageView)
        emptyChatStackView.addArrangedSubview(emptyChatTitleLabel)
        containerView.addSubview(newChatButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

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
    
    func showTicketBottomSheet() {
        guard ticketsBottomSheetView == nil else { return }
        
        let dimmedView = UIView()
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dimmedView)
        self.dimmedView = dimmedView
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissBottomSheetOnly))
        dimmedView.addGestureRecognizer(tapGesture)
        
        let bottomSheetView = TicketsBottomSheetView(configuration: viewModel.configuration) { [weak self] selectedTicket in
            guard let self else { return }
            self.dismissBottomSheet { [weak self] in
                guard let self = self else { return }
                self.showCreateTicketBottomSheet(category: selectedTicket)
            }
        }

        let bottomSheetHeight = UIScreen.main.bounds.height * 0.4

        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomSheetView)
        ticketsBottomSheetView = bottomSheetView
        
        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.topAnchor.constraint(equalTo: topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            bottomSheetView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSheetView.heightAnchor.constraint(equalToConstant: bottomSheetHeight)
        ])
        
        bottomSheetView.transform = CGAffineTransform(translationX: 0, y: bottomSheetHeight)
        bottomSheetView.alpha = 0
        dimmedView.alpha = 0

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            bottomSheetView.transform = .identity
            bottomSheetView.alpha = 1
            dimmedView.alpha = 1
        })
    }
    
    @objc private func dismissBottomSheetOnly() {
        dismissBottomSheet(completion: nil)
    }
    
    @objc func dismissBottomSheet(completion: (() -> Void)? = nil) {
        guard let bottomSheet = ticketsBottomSheetView,
              let dimmedView = dimmedView else {
            completion?()
            return
        }

        let localBottomSheet = bottomSheet
        let localDimmedView = dimmedView
        
        self.ticketsBottomSheetView = nil
        self.dimmedView = nil

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            localBottomSheet.transform = CGAffineTransform(translationX: 0, y: localBottomSheet.frame.height)
            localBottomSheet.alpha = 0
            localDimmedView.alpha = 0
        }) { _ in
            localBottomSheet.removeFromSuperview()
            localDimmedView.removeFromSuperview()
            completion?()
        }
    }
    
    private func showCreateTicketBottomSheet(category: String) {
        let createTicketView = CreateTicketBottomSheetView(
            viewModel: viewModel,
            selectedCategory: category,
            onDismiss: { [weak self] in
                guard let self = self else { return }
                self.dismissCreateTicketView {
                    self.delegate?.didCreateTicket()
                }
            }
        )
        createTicketView.translatesAutoresizingMaskIntoConstraints = false
        
        guard let window = window ?? UIApplication.shared.windows.first else { return }
        window.addSubview(createTicketView)
        window.rootViewController?.navigationController?.setNavigationBarHidden(true, animated: true)
        
        NSLayoutConstraint.activate([
            createTicketView.topAnchor.constraint(equalTo: window.topAnchor),
            createTicketView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            createTicketView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            createTicketView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])
        
        createTicketView.transform = CGAffineTransform(translationX: 0, y: window.bounds.height)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            createTicketView.transform = .identity
        })
    }

    private func dismissCreateTicketView(completion: (() -> Void)? = nil) {
        guard let createTicketView = window?.subviews.last as? CreateTicketBottomSheetView else { return }
        window?.rootViewController?.navigationController?.setNavigationBarHidden(false, animated: true)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            createTicketView.transform = CGAffineTransform(translationX: 0, y: self.window?.bounds.height ?? 0)
        }) { _ in
            createTicketView.removeFromSuperview()
            completion?()
        }
    }
}
