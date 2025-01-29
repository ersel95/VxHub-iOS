//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import UIKit
import Combine

final public class VxMainSubscriptionViewController: VxNiblessViewController {
    private let viewModel: VxMainSubscriptionViewModel
    private var rootView: UIView? // Type-erased root view
    private var disposeBag = Set<AnyCancellable>()
    
    public init(viewModel: VxMainSubscriptionViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
    }
    
    public override func loadView() {
        if viewModel.configuration.paywallType == VxMainPaywallTypes.v1.rawValue {
            let subscriptionRootView = VxMainSubscriptionRootView(viewModel: viewModel)
            self.rootView = subscriptionRootView
        } else {
            let subscriptionV2RootView = VxMainSubscriptionV2RootView(viewModel: viewModel)
            self.rootView = subscriptionV2RootView
        }
        self.view = rootView
    }
}

extension VxMainSubscriptionViewController: @preconcurrency VxMainSuvscriptionViewModelDelegate {
    func dismiss() {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true) {
                self?.viewModel.onDismissWithoutPurchase?()
            }
        }
    }
}

