#if canImport(UIKit)
import SwiftUI
import UIKit

@available(iOS 16.0, *)
public struct VxStoreView: UIViewControllerRepresentable {

    private let v1Configuration: VxStoreV1Configuration?
    private let v2Configuration: VxStoreV2Configuration?
    private let onPurchaseSuccess: @Sendable (String?) -> Void
    private let onDismiss: @Sendable () -> Void

    public init(
        v1Configuration: VxStoreV1Configuration? = nil,
        v2Configuration: VxStoreV2Configuration? = nil,
        onPurchaseSuccess: @escaping @Sendable (String?) -> Void = { _ in },
        onDismiss: @escaping @Sendable () -> Void = {}
    ) {
        self.v1Configuration = v1Configuration
        self.v2Configuration = v2Configuration
        self.onPurchaseSuccess = onPurchaseSuccess
        self.onDismiss = onDismiss
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let viewModel = VxStoreViewModel(
            v1Configuration: v1Configuration,
            v2Configuration: v2Configuration,
            onPurchaseSuccess: { [onPurchaseSuccess] productIdentifier in
                DispatchQueue.main.async {
                    onPurchaseSuccess(productIdentifier)
                }
            },
            onDismissWithoutPurchase: { [onDismiss] in
                DispatchQueue.main.async {
                    onDismiss()
                }
            }
        )

        guard !viewModel.cellViewModels.isEmpty else {
            VxLogger.shared.warning("[VxStore] No products to show")
            let empty = UIViewController()
            empty.view.backgroundColor = .clear
            DispatchQueue.main.async { onDismiss() }
            return empty
        }

        let storeVC = VxStoreViewController(viewModel: viewModel)
        return storeVC
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public final class Coordinator {
        var hasPresented = false
    }
}
#endif
