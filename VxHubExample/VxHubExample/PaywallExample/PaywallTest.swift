import UIKit
import VxHub


struct PaywallUIKitWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PaywallTestViewController {
        return PaywallTestViewController()
    }
    
    func updateUIViewController(_ uiViewController: PaywallTestViewController, context: Context) {
        // Updates handled in view controller
    }
}

class PaywallTestViewController: UIViewController {
    
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
        title = "Subscription Test"
    }
}

// SwiftUI Preview
import SwiftUI

struct PaywallTestViewController_Preview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            PaywallTestViewController()
        }
    }
}

// Helper for SwiftUI Preview
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
