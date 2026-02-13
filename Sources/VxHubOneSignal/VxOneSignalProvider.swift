#if os(iOS)
//
//  VxOneSignalProvider.swift
//  VxHub
//
//  Created by VxHub on 2025.
//

import Foundation
import UIKit
import VxHubCore
import OneSignalFramework

public final class VxOneSignalProvider: VxPushProvider, @unchecked Sendable {

    public init() {}

    // MARK: - VxPushProvider

    public func initialize(appId: String, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        OneSignal.initialize(appId, withLaunchOptions: launchOptions)
    }

    public func changeVid(for vid: String) {
        OneSignal.logout()
        OneSignal.login(vid)
    }

    public func addEmail(_ email: String) {
        OneSignal.User.addEmail(email)
    }

    public func login(_ externalId: String) {
        OneSignal.login(externalId)
    }

    public func logout() {
        OneSignal.logout()
    }

    public var playerId: String? {
        return OneSignal.User.pushSubscription.id
    }

    public var playerToken: String? {
        return OneSignal.User.pushSubscription.token
    }
}
#endif
