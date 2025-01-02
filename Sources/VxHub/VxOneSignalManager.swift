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
        OneSignal.login(VxHub.shared.deviceConfig!.UDID)
    }
        
    nonisolated public var playerId: String? {
        return OneSignal.User.pushSubscription.id
    }
    
    public var playerToken: String? {
        return OneSignal.User.pushSubscription.token
    }
}
