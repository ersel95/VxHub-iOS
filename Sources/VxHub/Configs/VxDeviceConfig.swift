//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation
import UIKit
import KeychainSwift

@MainActor
internal enum VxDeviceConfig {    
    public static let userType = "regular"
    public static let devicePlatform = "IOS"
    public static let deviceType = "phone"
    public static let deviceBrand = "Apple"
    public static let deviceModel = UIDevice.VxModelName.removingWhitespaces()
    public static let deviceCountry = Locale.current.region?.identifier ?? "xx"
    public static var deviceLang: String {
         get {
             let preferredLanguage = Locale.preferredLanguages.first ?? "en-EN"
             let languageCode = String(preferredLanguage.split(separator: "-").first ?? "en")             
             return UserDefaults.VxHub_prefferedLanguage ?? languageCode
         }
     }
    public static let idfaStatus = VxPermissionManager.shared.getIDFA()
    public static let op_region = deviceCountry
    public static let carrier_region = ""
    public static let os = UIDevice.current.systemVersion
    public static let battery = UIDevice.current.batteryLevel * 100
    public static let deviceOsVersion = UIDevice.current.systemVersion
    public static let deviceName = UIDevice.current.name.removingWhitespaces()
    public static let UDID = VxKeychainManager.shared.UDID

    public static var isOrganic: Bool = false
    public static let timeZone: String = TimeZone.current.abbreviation() ?? ""
    
    public static let resolution: String = {
        let screenSize = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        let width = Int(screenSize.width * scale)
        let height = Int(screenSize.height * scale)
        return "\(width)x\(height)"
    }()
}
