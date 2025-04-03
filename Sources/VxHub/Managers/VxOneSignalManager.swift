//
//  File.swift
//  VxHub
//
//  Created by furkan on 5.11.2024.
//

import Foundation
import UIKit
import OneSignalFramework

internal struct VxOneSignalManager {
    public init() {}
    
    public func initialize(appId: String, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        OneSignal.initialize(appId, withLaunchOptions: launchOptions)
        #if DEBUG
        OneSignal.login(VxHub.shared.deviceInfo!.vid!)
        #else
        OneSignal.login(VxHub.shared.deviceInfo?.vid ?? VxHub.shared.deviceConfig?.UDID ?? "")
        #endif
    }
    
    public func changeVid(for vid: String) {
        OneSignal.logout()
        OneSignal.login(vid)
    }
        
    nonisolated public var playerId: String? {
        return OneSignal.User.pushSubscription.id
    }
    
    public var playerToken: String? {
        return OneSignal.User.pushSubscription.token
    }
}
