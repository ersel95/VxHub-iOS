#if os(iOS)
//
//  VxFacebookProviderImpl.swift
//  VxHub
//
//  Created by VxHub on 2025.
//

import Foundation
import UIKit
import VxHubCore
import FacebookCore
import AppTrackingTransparency

public struct VxFacebookProviderImpl: VxFacebookProvider, Sendable {

    public init() {}

    // MARK: - VxFacebookProvider

    public var anonymousId: String {
        return FBSDKCoreKit.AppEvents.shared.anonymousID
    }

    public func initSdk(appId: String, clientToken: String, appName: String?) {
        Settings.shared.appID = appId
        Settings.shared.clientToken = clientToken
        if let appName = appName {
            Settings.shared.displayName = appName
        }
    }

    public func setupFacebook(application: UIApplication, didFinishLaunching: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: didFinishLaunching
        )
    }

    public func setAttFlag() {
        if #available(iOS 14.5, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .authorized:
                Settings.shared.isAdvertiserTrackingEnabled = true
            default:
                Settings.shared.isAdvertiserTrackingEnabled = false
            }
        } else {
            Settings.shared.isAdvertiserTrackingEnabled = true
        }
    }

    public func openFacebookUrl(_ url: URL, application: UIApplication) {
        ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}
#endif
