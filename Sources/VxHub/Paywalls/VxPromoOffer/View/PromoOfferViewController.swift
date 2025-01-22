import UIKit

final class PromoOfferViewController: VxNiblessViewController {
    
    // MARK: - Properties
    private let viewModel: PromoOfferViewModel
    private var rootView: PromoOfferRootView?
    
    // MARK: - Initialization
    init(viewModel: PromoOfferViewModel) {
        self.viewModel = viewModel
        super.init()
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        self.rootView = PromoOfferRootView(viewModel: viewModel)
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        viewModel.delegate = self
    }
    
    // MARK: - Setup
    private func setupBindings() {
    }
}

extension PromoOfferViewController: PromoOfferViewModelDelegate {
    nonisolated func promoOfferDidClose() {
        debugPrint("Dismiss geldi 1")
        DispatchQueue.main.async {
            debugPrint("Dismiss geldi 2")
            self.dismiss(animated: true) {
                debugPrint("Dismiss geldi 3")
                self.viewModel.onDismissWithoutPurchase?()
            }
        }
    }

    nonisolated func promoOfferDidClaim() {
//        DispatchQueue.main.async { [weak self] in
            // Handle the claim action, e.g., update the UI
//        }
    }
}

