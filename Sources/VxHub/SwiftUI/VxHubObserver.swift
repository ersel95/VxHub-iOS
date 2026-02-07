//
//  VxHubObserver.swift
//  VxHub
//
//  Created by VxHub
//

import SwiftUI
import UIKit
import Combine

/// An `ObservableObject` that lets SwiftUI views reactively observe VxHub state.
///
/// `VxHubObserver` automatically refreshes whenever VxHub posts a state-change
/// notification (e.g., premium status changes, product list updates, connectivity changes)
/// and also on `UIApplication.didBecomeActiveNotification` to pick up warm-start updates.
///
/// Usage:
/// ```swift
/// struct ContentView: View {
///     @StateObject private var hub = VxHubObserver()
///
///     var body: some View {
///         VStack {
///             if hub.isPremium {
///                 Text("Premium user")
///             }
///             Text("Balance: \(hub.balance)")
///             Text("Products: \(hub.revenueCatProducts.count)")
///
///             if !hub.isConnectedToInternet {
///                 Text("No internet connection")
///                     .foregroundColor(.red)
///             }
///         }
///     }
/// }
/// ```
@available(iOS 16.0, *)
@MainActor
public final class VxHubObserver: ObservableObject {

    // MARK: - Published Properties

    /// Whether the current user has an active premium subscription.
    @Published public private(set) var isPremium: Bool = false

    /// The user's current coin/credit balance.
    @Published public private(set) var balance: Int = 0

    /// Whether the device currently has an internet connection.
    @Published public private(set) var isConnectedToInternet: Bool = true

    /// The list of RevenueCat products available for purchase.
    /// Empty until `VxHub.shared` has finished initialization.
    @Published public private(set) var revenueCatProducts: [VxStoreProduct] = []

    /// Server-provided device info, or `nil` if the SDK has not initialized yet.
    @Published public private(set) var deviceInfo: VxDeviceInfo?

    /// Server-provided remote configuration dictionary.
    @Published public private(set) var remoteConfig: [String: Any] = [:]

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer

    public init() {
        refresh()

        // Observe VxHub state changes (premium, balance, connectivity, products)
        NotificationCenter.default.publisher(for: .vxHubStateDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)

        // Also refresh on app becoming active (warm start may update server data)
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    /// Re-reads all observable properties from `VxHub.shared`.
    /// Called automatically on state changes and app activation;
    /// you can also call it manually if needed.
    public func refresh() {
        isPremium = VxHub.shared.isPremium
        balance = VxHub.shared.balance
        isConnectedToInternet = VxHub.shared.isConnectedToInternet
        revenueCatProducts = VxHub.shared.revenueCatProducts
        deviceInfo = VxHub.shared.deviceInfo
        remoteConfig = VxHub.shared.remoteConfig
    }
}
