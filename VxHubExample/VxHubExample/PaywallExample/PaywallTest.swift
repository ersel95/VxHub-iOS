import UIKit
import VxHub
import SwiftUI

struct PaywallUIKitWrapper: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PaywallTestViewController {
        let vc = PaywallTestViewController()
        vc.dismissAction = {
            dismiss()
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PaywallTestViewController, context: Context) {}
}

class PaywallTestViewController: UIViewController {
    var dismissAction: (() -> Void)?
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var subscriptionRootView: VxMainSubscriptionRootView = {
        let viewModel = VxMainSubscriptionViewModel()
        let view = VxMainSubscriptionRootView(viewModel: viewModel)
        return view
    }()
    
    override func loadView() {
        view = subscriptionRootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
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
        dismissAction?()
    }
}

import SwiftUI

struct PaywallTestViewController_Preview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            PaywallTestViewController()
        }
    }
}

struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController
    
    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
} 
