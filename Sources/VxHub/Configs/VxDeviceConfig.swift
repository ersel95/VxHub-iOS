//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

@preconcurrency import Foundation
@preconcurrency import UIKit
@preconcurrency import KeychainSwift

internal class VxDeviceConfig : @unchecked Sendable {
    
    private init() {}
    internal static let shared = VxDeviceConfig()
    
    public var carrier_region = ""
    public var os = ""
    public var battery: Float = -1.0
    public var deviceOsVersion = ""
    public var deviceName = ""
    public var UDID = ""
    public var deviceModel = ""
    public var resolution = ""
    
    public var userType = "regular"
    public var devicePlatform = "IOS"
    public var deviceType = "phone"
    public var deviceBrand = "Apple"
    public var deviceCountry = Locale.current.region?.identifier ?? "xx"
    public var deviceLang: String {
         get {
             let preferredLanguage = Locale.preferredLanguages.first ?? "en-EN"
             let languageCode = String(preferredLanguage.split(separator: "-").first ?? "en")
             return UserDefaults.VxHub_prefferedLanguage ?? languageCode
         }
     }
    public var idfaStatus = VxPermissionManager.shared.getIDFA()
    public var op_region = Locale.current.region?.identifier ?? "xx"
    public var timeZone: String = TimeZone.current.abbreviation() ?? ""
}
