//
//  TicketListRootView.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 7.02.2025.
//

import UIKit
import Combine

protocol TicketListRootViewDelegate: AnyObject {
    func didSelectTicket(_ ticket: VxGetTicketsResponse)
}

final public class TicketListRootView: VxNiblessView {
    private let viewModel: VxSupportViewModel
    private var disposeBag = Set<AnyCancellable>()
    private var ticketsBottomSheetView: TicketsBottomSheetView?
    private var dimmedView: UIView?
    weak var delegate: TicketListRootViewDelegate?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = viewModel.configuration.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    public init(frame: CGRect = .zero, viewModel: VxSupportViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        subscribe()
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(ticketsTableView)
        containerView.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            ticketsTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32),
            ticketsTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            ticketsTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            ticketsTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func subscribe() {
        viewModel.$tickets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.ticketsTableView.reloadData()
            }
            .store(in: &disposeBag)
        
        viewModel.loadingStatePublisher
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
        
        viewModel.isPullToRefreshLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &disposeBag)
        
        NotificationCenter.default
            .publisher(for: .ticketCreated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.fetchTickets()
            }
            .store(in: &disposeBag)
    }
    
    @objc private func handleRefresh() {
        if viewModel.isPullToRefreshLoading.value {
            refreshControl.endRefreshing()
            return
        }
        
        viewModel.fetchTickets(isPullToRefresh: true)
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
    
    private func handleTicketSelection(_ category: String) {
        showCreateTicketBottomSheet(category: category)
    }
    
    private func showCreateTicketBottomSheet(category: String) {
        let createTicketView = CreateTicketBottomSheetView(
            viewModel: viewModel, 
            selectedCategory: category,
            onDismiss: { [weak self] in
                self?.dismissCreateTicketView()
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
    
    @objc private func dismissCreateTicketView() {
        guard let createTicketView = window?.subviews.last as? CreateTicketBottomSheetView else { return }
        window?.rootViewController?.navigationController?.setNavigationBarHidden(false, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            createTicketView.transform = CGAffineTransform(translationX: 0, y: self.window?.bounds.height ?? 0)
        }) { _ in
            createTicketView.removeFromSuperview()
        }
    }
}


extension TicketListRootView: UITableViewDelegate, UITableViewDataSource {
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
