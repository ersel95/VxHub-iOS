//
//  VxPaywallView.swift
//  VxHub
//
//  Created by VxHub
//

import SwiftUI
import UIKit

/// A SwiftUI wrapper for presenting the VxHub main paywall.
///
/// Usage:
/// ```swift
/// .fullScreenCover(isPresented: $showPaywall) {
///     VxPaywallView(
///         configuration: myConfig,
///         onPurchaseSuccess: { productId in
///             print("Purchased: \(productId ?? "restored")")
///         },
///         onDismiss: {
///             showPaywall = false
///         }
///     )
/// }
/// ```
@available(iOS 16.0, *)
public struct VxPaywallView: UIViewControllerRepresentable {

    // MARK: - Properties

    private let configuration: VxMainPaywallConfiguration
    private let onPurchaseSuccess: @Sendable (String?) -> Void
    private let onDismiss: @Sendable () -> Void
    private let onRestoreStateChange: @Sendable (Bool) -> Void
    private let onRedeemCodeButtonTapped: @Sendable () -> Void

    // MARK: - Initializer

    /// Creates a SwiftUI-compatible paywall view.
    /// - Parameters:
    ///   - configuration: The paywall configuration (fonts, colors, product layout, etc.).
    ///   - onPurchaseSuccess: Called when a purchase succeeds. The parameter is the product identifier,
    ///     or `nil` if the purchase was restored.
    ///   - onDismiss: Called when the paywall is dismissed without a purchase. You should set your
    ///     presentation binding to `false` inside this closure.
    ///   - onRestoreStateChange: Called with the result of a restore action (`true` if active subscription found).
    ///   - onRedeemCodeButtonTapped: Called when the user taps the redeem code button.
    public init(
        configuration: VxMainPaywallConfiguration,
        onPurchaseSuccess: @escaping @Sendable (String?) -> Void = { _ in },
        onDismiss: @escaping @Sendable () -> Void = {},
        onRestoreStateChange: @escaping @Sendable (Bool) -> Void = { _ in },
        onRedeemCodeButtonTapped: @escaping @Sendable () -> Void = {}
    ) {
        self.configuration = configuration
        self.onPurchaseSuccess = onPurchaseSuccess
        self.onDismiss = onDismiss
        self.onRestoreStateChange = onRestoreStateChange
        self.onRedeemCodeButtonTapped = onRedeemCodeButtonTapped
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
            VxHub.shared.showMainPaywall(
                from: uiViewController,
                configuration: configuration,
                presentationStyle: VxPaywallPresentationStyle.present.rawValue,
                completion: { [onPurchaseSuccess, onDismiss] success, productIdentifier in
                    if success {
                        onPurchaseSuccess(productIdentifier)
                    } else {
                        onDismiss()
                    }
                },
                onRestoreStateChange: { [onRestoreStateChange] restoreSuccess in
                    onRestoreStateChange(restoreSuccess)
                },
                onReedemCodeButtonTapped: { [onRedeemCodeButtonTapped] in
                    onRedeemCodeButtonTapped()
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
