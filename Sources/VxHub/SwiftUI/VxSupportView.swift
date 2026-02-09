#if canImport(UIKit)
//
//  VxSupportView.swift
//  VxHub
//
//  Created by VxHub
//

import SwiftUI
import UIKit

/// A SwiftUI wrapper for presenting the VxHub customer support screen.
///
/// The support screen is embedded inside a `UINavigationController` because it uses
/// UIKit push navigation internally for ticket detail views.
///
/// Usage:
/// ```swift
/// NavigationLink("Contact Us") {
///     VxSupportView(configuration: VxSupportConfiguration())
/// }
///
/// // Or as a sheet:
/// .sheet(isPresented: $showSupport) {
///     VxSupportView()
/// }
/// ```
@available(iOS 16.0, *)
public struct VxSupportView: UIViewControllerRepresentable {

    // MARK: - Properties

    private let configuration: VxSupportConfiguration

    // MARK: - Initializer

    /// Creates a SwiftUI-compatible support view.
    /// - Parameter configuration: The support UI configuration (colors, fonts, images).
    ///   Uses default values if not provided.
    public init(configuration: VxSupportConfiguration = VxSupportConfiguration()) {
        self.configuration = configuration
    }

    // MARK: - UIViewControllerRepresentable

    public func makeUIViewController(context: Context) -> UINavigationController {
        // Create a lightweight host VC that will serve as the appController
        // for the VxSupportViewModel (it uses appController for push navigation).
        let hostController = UIViewController()
        hostController.view.backgroundColor = .clear

        let navigationController = UINavigationController(rootViewController: hostController)

        // Build the support VC using the same pattern as VxHub.shared.showContactUs
        let viewModel = VxSupportViewModel(
            appController: navigationController,
            configuration: configuration
        )
        let supportController = VxSupportViewController(viewModel: viewModel)
        supportController.hidesBottomBarWhenPushed = true

        // Replace the host with the support VC so the user sees it immediately
        navigationController.setViewControllers([supportController], animated: false)

        return navigationController
    }

    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Configuration is immutable after creation; no updates needed.
    }
}
#endif
