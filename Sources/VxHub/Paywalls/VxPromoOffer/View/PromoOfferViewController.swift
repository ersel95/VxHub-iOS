import UIKit

public enum PromoOfferType {
    case v1
    case v2
}

public class PromoOfferViewController: VxNiblessViewController {
    
    // MARK: - Properties
    private let viewModel: PromoOfferViewModel
    private let type: PromoOfferType
    private var rootView: VxNiblessView?
    
    // MARK: - Initialization
    public init(viewModel: PromoOfferViewModel, type: PromoOfferType = .v1) {
        self.viewModel = viewModel
        self.type = type
        super.init()
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    public override func loadView() {
        switch type {
        case .v1:
            self.rootView = PromoOfferRootView(viewModel: viewModel)
        case .v2:
            self.rootView = PromoOfferV2RootView(viewModel: viewModel)
        }
        self.view = rootView
    }
    
    public override func viewDidLoad() {
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
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
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

