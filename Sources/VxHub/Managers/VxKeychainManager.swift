//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation
import UIKit.UIDevice
import KeychainSwift

internal struct VxKeychainManager {
    public init() {}
    
    private let keychain = KeychainSwift()
    var appleId: String?
    
    private func set(key: String, value: String) {
        self.keychain.set(value, forKey: key)
    }
    
    private func get(key: String) -> String? {
        return self.keychain.get(key)
    }

    private enum forKey {
        case UDID
        
        var value: String {
            switch self {
            case .UDID: return "DeviceUDID"
            }
        }
    }
    
    public var UDID: String {
        get {
            if let savedUDID = get(key: VxKeychainManager.forKey.UDID.value) {
                return savedUDID
            } else {
                let newUDID = appleId ?? VxHub.shared.deviceConfig?.appleId ?? UUID().uuidString
                set(key: VxKeychainManager.forKey.UDID.value, value: newUDID)
                return newUDID
            }
        }
        set {
            set(key: VxKeychainManager.forKey.UDID.value, value: newValue)
        }
    }
}
