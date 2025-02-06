//
//  VxSupportViewController.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 4.02.2025.
//

import UIKit
import Combine

final public class VxSupportViewController: VxNiblessViewController {
    private let viewModel: VxSupportViewModel
    private var rootView: VxSupportRootView!
    private var disposeBag = Set<AnyCancellable>()
    
    public init(viewModel: VxSupportViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        observeStateChanges()
        observeLoadingState()
    }
    
    private func setupNavigation() {
        title = "Contact us"
        navigationController?.navigationBar.tintColor = viewModel.configuration.navigationTintColor
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: viewModel.configuration.navigationTintColor,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]
    }
    
    private func observeStateChanges() {
        rootView.statePublisher
            .sink { [weak self] state in
                self?.updateNavigationItems(for: state)
            }
            .store(in: &disposeBag)
    }
    
    private func observeLoadingState() {
        viewModel.loadingStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.navigationItem.rightBarButtonItem?.isEnabled = !isLoading
            }
            .store(in: &disposeBag)
    }
    
    private func updateNavigationItems(for state: ContactUsState) {
        switch state {
        case .emptyTicket, .chatList:
            let newChatButton = UIBarButtonItem(
                image: UIImage(named: "new_chat_icon", in: .module, compatibleWith: nil),
                style: .plain,
                target: self,
                action: #selector(newChatTapped)
            )
            navigationItem.rightBarButtonItem = newChatButton
        case .newChat, .chatScreen:
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func newChatTapped() {
        rootView.showTicketBottomSheet()
    }
    
    public override func loadView() {
        rootView = VxSupportRootView(viewModel: viewModel)
        self.view = rootView
    }
}
