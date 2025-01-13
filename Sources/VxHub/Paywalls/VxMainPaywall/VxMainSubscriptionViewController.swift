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
    private var rootView: VxMainSubscriptionRootView?
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
        self.rootView = VxMainSubscriptionRootView(viewModel: viewModel)
        self.view = rootView
    }
    
    @objc private func closeTapped() {
        self.dismiss(animated: true)
    }
}

extension VxMainSubscriptionViewController: @preconcurrency VxMainSuvscriptionViewModelDelegate {
    func dismiss() {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}
