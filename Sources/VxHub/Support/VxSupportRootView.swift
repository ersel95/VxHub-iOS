//
//  VxSupportRootView.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 4.02.2025.
//

import UIKit
import Combine

protocol VxSupportRootViewDelegate: AnyObject {
    func createNewTicket(_ newTicket: String)
    func didSelectTicket(_ ticket: VxGetTicketsResponse)
}

final public class VxSupportRootView: VxNiblessView {
    private let viewModel: VxSupportViewModel
    private var disposeBag = Set<AnyCancellable>()
    weak var delegate: VxSupportRootViewDelegate?
    private var ticketsBottomSheetView: TicketsBottomSheetView?
    private var dimmedView: UIView?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = viewModel.configuration.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var emptyTicketContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var emptyChatStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center
        stack.distribution = .fill
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
        label.text = VxLocalizables.Support.emptyTicketTitleLabel
        label.setFont(viewModel.configuration.font, size: 14, weight: .medium)
        label.textColor = viewModel.configuration.listingDescriptionColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var spacerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var newChatButton: VxButton = {
        let button = VxButton(font: viewModel.configuration.font,
                             fontSize: 14,
                             weight: .bold)
        button.configure(backgroundColor: viewModel.configuration.listingActionColor,
                        foregroundColor: viewModel.configuration.listingActionTextColor,
                        cornerRadius: 8)
        button.setTitle(VxLocalizables.Support.newChatButtonText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(newTicketButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func newTicketButtonTapped() {
        showTicketBottomSheet()
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = viewModel.configuration.navigationTintColor
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var ticketsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TicketListCell.self, forCellReuseIdentifier: TicketListCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = .zero
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = viewModel.configuration.navigationTintColor
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    
    @objc private func handleRefresh() {
        if viewModel.isPullToRefreshLoading.value {
            refreshControl.endRefreshing()
            return
        }
        
        viewModel.fetchTickets(isPullToRefresh: true)
    }

    public init(frame: CGRect = .zero, viewModel: VxSupportViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        subscribe()
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(loadingIndicator)
        containerView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(emptyTicketContainerStackView)
        containerStackView.addArrangedSubview(ticketsTableView)
        
        emptyTicketContainerStackView.addArrangedSubview(emptyChatStackView)
        emptyTicketContainerStackView.addArrangedSubview(spacerView)
        emptyTicketContainerStackView.addArrangedSubview(newChatButton)
        emptyChatStackView.addArrangedSubview(emptyChatImageView)
        emptyChatStackView.addArrangedSubview(emptyChatTitleLabel)
        
        containerStackView.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            containerStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            containerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            containerStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            emptyTicketContainerStackView.topAnchor.constraint(equalTo: containerStackView.topAnchor),
            emptyTicketContainerStackView.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor),
            emptyTicketContainerStackView.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor),
            emptyTicketContainerStackView.bottomAnchor.constraint(equalTo: containerStackView.bottomAnchor),

            emptyChatStackView.topAnchor.constraint(equalTo: emptyTicketContainerStackView.topAnchor, constant: 104),
            emptyChatStackView.leadingAnchor.constraint(equalTo: emptyTicketContainerStackView.leadingAnchor),
            emptyChatStackView.trailingAnchor.constraint(equalTo: emptyTicketContainerStackView.trailingAnchor),
            
            emptyChatImageView.widthAnchor.constraint(equalToConstant: 64),
            emptyChatImageView.heightAnchor.constraint(equalToConstant: 64),
            
            newChatButton.leadingAnchor.constraint(equalTo: emptyTicketContainerStackView.leadingAnchor),
            newChatButton.trailingAnchor.constraint(equalTo: emptyTicketContainerStackView.trailingAnchor),
            newChatButton.bottomAnchor.constraint(equalTo: emptyTicketContainerStackView.bottomAnchor, constant: -11),
            newChatButton.heightAnchor.constraint(equalToConstant: 48),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            ticketsTableView.topAnchor.constraint(equalTo: containerStackView.topAnchor, constant: 32),
            ticketsTableView.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor),
            ticketsTableView.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor),
            ticketsTableView.bottomAnchor.constraint(equalTo: containerStackView.bottomAnchor)
        ])
    }
    
    private func subscribe() {
        viewModel.$tickets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tickets in
                self?.ticketsTableView.reloadData()
                self?.updateViewsVisibility()
            }
            .store(in: &disposeBag)
        
        viewModel.loadingStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.handleLoadingState(isLoading)
            }
            .store(in: &disposeBag)
        
        viewModel.isPullToRefreshLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &disposeBag)
    }

    private func handleLoadingState(_ isLoading: Bool) {
        containerView.isUserInteractionEnabled = !isLoading
        
        if isLoading {
            loadingIndicator.startAnimating()
            containerStackView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            containerStackView.isHidden = false
            updateViewsVisibility()
        }
    }

    private func updateViewsVisibility() {
        let isEmpty = viewModel.tickets.isEmpty
        emptyTicketContainerStackView.isHidden = !isEmpty
        ticketsTableView.isHidden = isEmpty
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
        
        let bottomSheetView = TicketsBottomSheetView(configuration: viewModel.configuration) { [weak self] newTicket in
            guard let self else { return }
            self.dismissBottomSheet { [weak self] in
                guard let self = self else { return }
                self.delegate?.createNewTicket(newTicket)
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
}

extension VxSupportRootView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tickets.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TicketListCell.identifier, for: indexPath) as? TicketListCell else {
            return UITableViewCell()
        }
        
        let item = viewModel.tickets[indexPath.row]
        cell.configure(with: item, configuration: viewModel.configuration)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.tickets[indexPath.row]
        delegate?.didSelectTicket(item)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
