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
    var dismissAction: (() -> Void)?
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    public init(viewModel: VxMainSubscriptionViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
    }
    
    public override func loadView() {
        self.rootView = VxMainSubscriptionRootView(viewModel: viewModel)
        self.view = rootView
    }
    
    private func setupCloseButton() {
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc private func closeTapped() {
//        dismissAction?()
        self.dismiss(animated: true)
    }
}
