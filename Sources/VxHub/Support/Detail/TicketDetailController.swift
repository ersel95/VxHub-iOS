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
    private let ticket: VxGetTicketsResponse?
    private let newTicket: String?
    private var rootView: TicketDetailRootView!
    private var disposeBag = Set<AnyCancellable>()
    
    public init(viewModel: VxSupportViewModel, ticket: VxGetTicketsResponse? = nil, newTicket: String? = nil) {
        self.viewModel = viewModel
        self.ticket = ticket
        self.newTicket = newTicket
        super.init()
        viewModel.isNewTicket = newTicket != nil
    }
    
    public override func loadView() {
        rootView = TicketDetailRootView(viewModel: viewModel, category: newTicket)
        self.view = rootView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        if !viewModel.isNewTicket {
            loadTicketMessages()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.viewModel.onStateChange?(.detail)
        self.hidesBottomBarWhenPushed = true
        if !viewModel.isNewTicket {
            loadTicketMessages()
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.onStateChange?(.list)
        if isMovingFromParent {
            viewModel.clearTicketMessages()
        }
    }
    
    private func loadTicketMessages() {
        guard let ticket else { return }
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
        title = VxLocalizables.Support.navigationTitle
        navigationController?.navigationBar.tintColor = viewModel.configuration.navigationTintColor
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: viewModel.configuration.navigationTintColor,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]
    }
}
