//
//  File.swift
//  VxHub
//
//  Created by furkan on 4.11.2024.
//

import Foundation
import FacebookCore
import AppTrackingTransparency

open class VxFacebookManager: @unchecked Sendable {
    
    public static let shared = VxFacebookManager()
    
    public var facebookAnonymousId : String {
        return FBSDKCoreKit.AppEvents.shared.anonymousID
    }
    
    public var canInitializeFacebook: Bool {
        guard let infoDict = Bundle.main.infoDictionary else { return false }
        let facebookKeys = ["FacebookAppID", "FacebookClientToken"]
        let facebookKeysExist = facebookKeys.allSatisfy { infoDict[$0] != nil }
        let urlSchemeKey = "CFBundleURLTypes"
        let urlSchemeExists = (infoDict[urlSchemeKey] as? [[String: Any]])?.contains {
            guard let schemes = $0["CFBundleURLSchemes"] as? [String] else { return false }
            return schemes.contains(where: { $0.starts(with: "fb") })
        } ?? false
        
        if !facebookKeysExist || !urlSchemeExists {
            debugPrint("VXHUB: Could not initialize fb due to missing plist keys. ") //TODO: - Handle with logger
            return false
        }
        
        return facebookKeysExist && urlSchemeExists
    }
    
    public func initFbSdk(appId: String, clientToken: String, appName: String?) {
        Settings.shared.appID = appId
        Settings.shared.clientToken = clientToken
        if let appName = appName {
            Settings.shared.displayName = appName
        }
        
        // Optionally log to confirm the initialization
        debugPrint("VXHUB: Facebook SDK initialized with App ID: \(appId), Client Token: \(clientToken), App Name: \(appName ?? "N/A")")
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
}
