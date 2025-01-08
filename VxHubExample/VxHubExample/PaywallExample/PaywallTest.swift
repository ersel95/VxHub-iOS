import UIKit
import VxHub
import SwiftUI

struct PaywallUIKitWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PaywallTestViewController {
        let vc = PaywallTestViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PaywallTestViewController, context: Context) {
    }
}

class PaywallTestViewController: UIViewController {
    
    private lazy var subscriptionRootView: VxMainSubscriptionRootView = {
        let viewModel = VxMainSubscriptionViewModel()
        let view = VxMainSubscriptionRootView(viewModel: viewModel)
        return view
    }()
    
    override func loadView() {
        self.view = subscriptionRootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
