//
//  VxSupportTicketListController.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 7.02.2025.
//

import UIKit
import Combine

final public class TicketListController: VxNiblessViewController {
    private let viewModel: VxSupportViewModel
    private var rootView: TicketListRootView!
    private var disposeBag = Set<AnyCancellable>()
    
    public init(viewModel: VxSupportViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    public override func loadView() {
        rootView = TicketListRootView(viewModel: viewModel)
        rootView.delegate = self
        self.view = rootView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        observeLoadingState()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchTickets()
    }
    
    private func setupNavigation() {
        title = "Contact us"
        navigationController?.navigationBar.tintColor = viewModel.configuration.navigationTintColor
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: viewModel.configuration.navigationTintColor,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]
        let newTicketButton = UIBarButtonItem(
            image: UIImage(named: "new_chat_icon", in: .module, compatibleWith: nil),
            style: .plain,
            target: self,
            action: #selector(newTicketButtonTapped)
        )
        navigationItem.rightBarButtonItem = newTicketButton
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @objc private func newTicketButtonTapped() {
        rootView.showTicketBottomSheet()
    }
    
    private func observeLoadingState() {
        viewModel.loadingStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.navigationItem.rightBarButtonItem?.isEnabled = !isLoading
            }
            .store(in: &disposeBag)
    }
}

extension TicketListController: @preconcurrency TicketListRootViewDelegate {
    func didSelectTicket(_ ticket: VxGetTicketsResponse) {
        let detailController = TicketDetailController(viewModel: viewModel, ticket: ticket)
        navigationController?.pushViewController(detailController, animated: true)
    }
}
