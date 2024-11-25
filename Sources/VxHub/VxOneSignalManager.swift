//
//  File.swift
//  VxHub
//
//  Created by furkan on 5.11.2024.
//

import Foundation
import UIKit
import OneSignalFramework

open class VxOneSignalManager: @unchecked Sendable {
    
    public static let shared = VxOneSignalManager()
    private init() {}
    
    @MainActor
    public func initialize(appId: String, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        OneSignal.initialize(appId, withLaunchOptions: launchOptions)
        OneSignal.login(VxDeviceConfig.UDID)
    }
    
    nonisolated public var playerId: String? {
        OneSignal.User.pushSubscription.id
    }
    
    public var playerToken: String? {
        OneSignal.User.pushSubscription.token
    }
}
