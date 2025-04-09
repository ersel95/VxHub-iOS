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
        case appleLoginFullName
        case appleLoginEmail
        case retentionCoin
        case activeNonConsumables // will be [String:Bool]
        
        var value: String {
            switch self {
            case .UDID: return "DeviceUDID"
            case .appleLoginEmail: return "AppleLoginEmail"
            case .appleLoginFullName: return "AppleLoginFullName"
            case .retentionCoin: return "RetentionCoin"
            case .activeNonConsumables: return "ActiveNonConsumables"
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
    
    public func setAppleLoginDatas(_ fullName: String?, _ email: String?) {
        if let email {
            set(key: VxKeychainManager.forKey.appleLoginEmail.value, value: email)
        }
        if let fullName {
            set(key: VxKeychainManager.forKey.appleLoginFullName.value, value: fullName)
        }
    }
    
    func getAppleEmail() -> String? {
        if let savedEmail = get(key: VxKeychainManager.forKey.appleLoginEmail.value) {
            return savedEmail
        }else{
            return nil
        }
    }
    
    func getAppleLoginFullName() -> String? {
        if let savedEmail = get(key: VxKeychainManager.forKey.appleLoginFullName.value) {
            return savedEmail
        } else {
            return nil
        }
    }
    
    func markRetentionCoinGiven() {
        set(key: VxKeychainManager.forKey.retentionCoin.value, value: "true")
    }
    
    func hasGivenRetentionCoin() -> Bool {
        if let savedRetentionCoin = get(key: VxKeychainManager.forKey.retentionCoin.value) {
            return savedRetentionCoin == "true"
        } else {
            return false
        }
    }

    public func setNonConsumable(_ productId: String, isActive: Bool) {
        var nonConsumables = getNonConsumables()
        nonConsumables[productId] = isActive
        if let jsonData = try? JSONSerialization.data(withJSONObject: nonConsumables, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            set(key: VxKeychainManager.forKey.activeNonConsumables.value, value: jsonString)
        }
    }

    public func removeNonConsumable(_ productId: String) {
        var nonConsumables = getNonConsumables()
        nonConsumables.removeValue(forKey: productId)
        if let jsonData = try? JSONSerialization.data(withJSONObject: nonConsumables, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            set(key: VxKeychainManager.forKey.activeNonConsumables.value, value: jsonString)
        }
    }

    public func isNonConsumableActive(_ productId: String) -> Bool {
        let nonConsumables = getNonConsumables()
        return nonConsumables[productId] ?? false
    }

    public func getNonConsumables() -> [String: Bool] {
        if let jsonString = get(key: VxKeychainManager.forKey.activeNonConsumables.value),
           let jsonData = jsonString.data(using: .utf8),
           let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Bool] {
            return dictionary
        }
        return [:] // Return empty dictionary if nothing exists or parsing fails
    }

    public func clearNonConsumables() {
        keychain.delete(VxKeychainManager.forKey.activeNonConsumables.value)
    }
}
