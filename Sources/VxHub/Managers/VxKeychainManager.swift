//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation
import UIKit.UIDevice
import KeychainSwift

final internal class VxKeychainManager: @unchecked Sendable {
    
    private struct Static {
        nonisolated(unsafe) fileprivate static var instance: VxKeychainManager?
    }
    
    class var shared: VxKeychainManager {
        if let currentInstance = Static.instance {
            return currentInstance
        } else {
            Static.instance = VxKeychainManager()
            return Static.instance!
        }
    }
    
    func dispose() {
        VxKeychainManager.Static.instance = nil
    }
    
    let keychain = KeychainSwift()

    private func set(key: String, value: String) {
        self.keychain.set(value, forKey: key)
    }
    
    private func get(key: String) -> String?{
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
            var udid = ""
            if let id = VxKeychainManager.shared.get(key: VxKeychainManager.forKey.UDID.value) {
                udid = String(format: "%@", id)
                
            } else {
                DispatchQueue.main.sync {
                    udid = UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: "")
                    self.UDID = udid
                }
                
            }
            VxKeychainManager.shared.dispose()
            return  udid
        }
        
        set(value) {
            VxKeychainManager.shared.set(key: VxKeychainManager.forKey.UDID.value, value: value)
        }
    }
}
