#if canImport(UIKit)
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
        // V4: Apple Guideline 3.1.2(c) compliant paywall — billed price is most prominent,
        // trial info is subordinate, CTA always includes price.
        // Entry point: VxHub.shared.showPaywallV4(from:configuration:...)
        // Configuration: VxMainPaywallV4Configuration (identical API to V3)
        } else if viewModel.configuration.paywallType == VxMainPaywallTypes.v4.rawValue,
                  let v4Config = viewModel.v4Configuration {
            let v4RootView = VxMainSubscriptionV4RootView(viewModel: viewModel, v4Configuration: v4Config)
            self.rootView = v4RootView
        } else if viewModel.configuration.paywallType == VxMainPaywallTypes.v3.rawValue,
                  let v3Config = viewModel.v3Configuration {
            let v3RootView = VxMainSubscriptionV3RootView(viewModel: viewModel, v3Configuration: v3Config)
            self.rootView = v3RootView
        } else {
            let subscriptionV2RootView = VxMainSubscriptionV2RootView(viewModel: viewModel)
            self.rootView = subscriptionV2RootView
        }
        self.view = rootView
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let v2RootView = rootView as? VxMainSubscriptionV2RootView {
            v2RootView.viewWillDisappear()
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let v2RootView = rootView as? VxMainSubscriptionV2RootView {
            v2RootView.viewDidAppear()
        }
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
#endif

