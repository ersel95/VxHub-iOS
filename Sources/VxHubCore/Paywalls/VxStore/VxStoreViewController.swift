#if canImport(UIKit)
import UIKit
import Combine

final public class VxStoreViewController: VxNiblessViewController {
    private let viewModel: VxStoreViewModel
    private var rootView: UIView?

    public init(viewModel: VxStoreViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
    }

    public override func loadView() {
        if viewModel.storeType == .v1, let config = viewModel.v1Configuration {
            let v1RootView = VxStoreV1RootView(viewModel: viewModel, configuration: config)
            self.rootView = v1RootView
        } else if let config = viewModel.v2Configuration {
            let v2RootView = VxStoreV2RootView(viewModel: viewModel, configuration: config)
            self.rootView = v2RootView
        }
        self.view = rootView
    }
}

extension VxStoreViewController: @preconcurrency VxStoreViewModelDelegate {
    func dismiss() {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true) {
                self?.viewModel.onDismissWithoutPurchase?()
            }
        }
    }
}
#endif
