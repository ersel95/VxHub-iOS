//
//  TicketDetailController.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 7.02.2025.
//

import UIKit
import Combine

final public class TicketDetailController: VxNiblessViewController {
    private let viewModel: VxSupportViewModel
    private let ticket: VxGetTicketsResponse
    private var rootView: TicketDetailRootView!
    private var disposeBag = Set<AnyCancellable>()
    
    public init(viewModel: VxSupportViewModel, ticket: VxGetTicketsResponse) {
        self.viewModel = viewModel
        self.ticket = ticket
        super.init()
    }
    
    public override func loadView() {
        rootView = TicketDetailRootView(viewModel: viewModel)
        self.view = rootView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        observeLoadingState()
        loadTicketMessages()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTicketMessages()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            viewModel.clearTicketMessages()
        }
    }
    
    private func loadTicketMessages() {
        viewModel.clearTicketMessages()
        viewModel.getTicketMessagesById(ticketId: ticket.id) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.rootView.chatTableView.reloadData()
                }
            }
        }
    }
    
    private func setupNavigation() {
        title = "Contact us"
        navigationController?.navigationBar.tintColor = viewModel.configuration.navigationTintColor
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: viewModel.configuration.navigationTintColor,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]
    }
    
    private func observeLoadingState() {
        viewModel.loadingStateTicketMessagesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.navigationItem.rightBarButtonItem?.isEnabled = !isLoading
            }
            .store(in: &disposeBag)
    }
}
