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
    
    public override func loadView() {
        rootView = VxSupportRootView(viewModel: viewModel)
        rootView.delegate = self
        self.view = rootView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
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
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @objc private func newTicketButtonTapped() {
        rootView.showTicketBottomSheet()
    }
}

extension VxSupportViewController: @preconcurrency VxSupportRootViewDelegate {
    func didCreateTicket() {
        let listController = TicketListController(viewModel: viewModel)
        navigationController?.pushViewController(listController, animated: true)
    }
}
