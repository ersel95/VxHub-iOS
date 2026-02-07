//
//  VxPromoOfferView.swift
//  VxHub
//
//  Created by VxHub
//

import SwiftUI
import UIKit

/// A SwiftUI wrapper for presenting a VxHub promotional offer.
///
/// Usage:
/// ```swift
/// .fullScreenCover(isPresented: $showPromo) {
///     VxPromoOfferView(
///         productIdentifier: "com.app.yearly",
///         productToCompareIdentifier: "com.app.monthly",
///         type: .v1,
///         onPurchaseSuccess: {
///             showPromo = false
///         },
///         onDismiss: {
///             showPromo = false
///         }
///     )
/// }
/// ```
@available(iOS 16.0, *)
public struct VxPromoOfferView: UIViewControllerRepresentable {

    // MARK: - Properties

    private let productIdentifier: String?
    private let productToCompareIdentifier: String?
    private let type: PromoOfferType
    private let onPurchaseSuccess: @Sendable () -> Void
    private let onDismiss: @Sendable () -> Void

    // MARK: - Initializer

    /// Creates a SwiftUI-compatible promo offer view.
    /// - Parameters:
    ///   - productIdentifier: The product identifier to offer. If `nil`, the SDK falls back
    ///     to the welcome offer or first available product.
    ///   - productToCompareIdentifier: An optional product identifier used for price comparison display.
    ///   - type: The promo offer UI variant (`.v1` or `.v2(videoBundleName:)`).
    ///   - onPurchaseSuccess: Called when the purchase succeeds.
    ///   - onDismiss: Called when the promo is dismissed without a purchase. You should set your
    ///     presentation binding to `false` inside this closure.
    public init(
        productIdentifier: String? = nil,
        productToCompareIdentifier: String? = nil,
        type: PromoOfferType = .v1,
        onPurchaseSuccess: @escaping @Sendable () -> Void = {},
        onDismiss: @escaping @Sendable () -> Void = {}
    ) {
        self.productIdentifier = productIdentifier
        self.productToCompareIdentifier = productToCompareIdentifier
        self.type = type
        self.onPurchaseSuccess = onPurchaseSuccess
        self.onDismiss = onDismiss
    }

    // MARK: - UIViewControllerRepresentable

    public func makeUIViewController(context: Context) -> UIViewController {
        let hostController = UIViewController()
        hostController.view.backgroundColor = .clear
        return hostController
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Guard against presenting multiple times
        guard !context.coordinator.hasPresented else { return }
        context.coordinator.hasPresented = true

        // Defer presentation to the next run loop tick so the host controller
        // is fully in the view hierarchy before we present on top of it.
        DispatchQueue.main.async {
            VxHub.shared.showPromoOffer(
                from: uiViewController,
                productIdentifier: productIdentifier,
                productToCompareIdentifier: productToCompareIdentifier,
                presentationStyle: VxPaywallPresentationStyle.present.rawValue,
                type: type,
                completion: { [onPurchaseSuccess, onDismiss] success in
                    if success {
                        onPurchaseSuccess()
                    } else {
                        onDismiss()
                    }
                }
            )
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // MARK: - Coordinator

    public final class Coordinator {
        var hasPresented = false
    }
}
