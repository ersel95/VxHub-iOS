#if os(iOS)
//
//  File.swift
//  VxHub
//
//  Created by furkan on 4.11.2024.
//

import Foundation
import VxHubCore
import FacebookCore
import AppTrackingTransparency

struct VxFacebookManager {
    
    public init() {}
    
    public var facebookAnonymousId : String {
        return FBSDKCoreKit.AppEvents.shared.anonymousID
    }
    
    public func initFbSdk(appId: String, clientToken: String, appName: String?) {
        Settings.shared.appID = appId
        Settings.shared.clientToken = clientToken
        if let appName = appName {
            Settings.shared.displayName = appName
        }
    }
    
    public func fbAttFlag() {
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
    
    public func setupFacebook(
        application: UIApplication,
        didFinishLaunching: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: didFinishLaunching
        )
    }
    
    public func openFacebookUrl(_ url: URL, application: UIApplication, options: [UIApplication.OpenURLOptionsKey: Any]? = nil) {
        ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}
#endif
