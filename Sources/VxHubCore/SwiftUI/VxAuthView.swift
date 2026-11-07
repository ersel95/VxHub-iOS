#if canImport(UIKit)
//
//  VxAuthView.swift
//  VxHub
//

import SwiftUI
import UIKit

/// A SwiftUI wrapper for the ready-made sign-in flow.
///
/// Which sign-in methods appear comes from the VxHub panel, so this needs no
/// arguments to decide what to draw.
///
/// ```swift
/// .fullScreenCover(isPresented: $showAuth) {
///     VxAuthView { result in
///         if case .signedIn(let user) = result { print("Signed in: \(user.email ?? "")") }
///         showAuth = false
///     }
/// }
/// ```
@available(iOS 16.0, *)
public struct VxAuthView: UIViewControllerRepresentable {

    private let configuration: VxAuthConfiguration
    private let startingStep: VxAuthStep
    private let onFinish: (VxAuthResult) -> Void

    public init(
        configuration: VxAuthConfiguration = VxAuthConfiguration(),
        startingAt startingStep: VxAuthStep = .signIn,
        onFinish: @escaping (VxAuthResult) -> Void
    ) {
        self.configuration = configuration
        self.startingStep = startingStep
        self.onFinish = onFinish
    }

    public func makeUIViewController(context: Context) -> VxAuthViewController {
        VxAuthViewController(
            configuration: configuration,
            startingAt: startingStep,
            onFinish: onFinish
        )
    }

    public func updateUIViewController(_ uiViewController: VxAuthViewController, context: Context) {
        // Configuration is fixed once presented; nothing to push down.
    }
}

/// Observable auth state for SwiftUI, mirroring `VxHubObserver`.
///
/// ```swift
/// @StateObject private var auth = VxAuthObserver()
/// if auth.isAuthenticated { ProfileView() } else { SignInPrompt() }
/// ```
@available(iOS 16.0, *)
@MainActor
public final class VxAuthObserver: ObservableObject {
    @Published public private(set) var user: VxUser?
    @Published public private(set) var isAuthenticated: Bool
    @Published public private(set) var config: VxAuthConfig?

    // nonisolated(unsafe) because deinit runs outside the actor and Swift 6
    // will not let it touch actor state otherwise. The token is only written
    // once, in init, so there is nothing to race with.
    private nonisolated(unsafe) var observer: NSObjectProtocol?

    public init() {
        user = VxHub.shared.currentUser
        isAuthenticated = VxHub.shared.isAuthenticated
        config = VxHub.shared.authConfig

        observer = NotificationCenter.default.addObserver(
            forName: .vxHubAuthStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.refresh()
            }
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func refresh() {
        user = VxHub.shared.currentUser
        isAuthenticated = VxHub.shared.isAuthenticated
        config = VxHub.shared.authConfig
    }
}
#endif
