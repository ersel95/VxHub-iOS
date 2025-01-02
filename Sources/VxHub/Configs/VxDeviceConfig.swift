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
    
    public func initializeConfig(
        carrier_region: String,
        os: String,
        battery: Float,
        deviceOsVersion: String,
        deviceName: String,
        UDID: String,
        deviceModel: String,
        resolution: String,
        appleId: String
    ) {
        self.carrier_region = carrier_region
        self.os = os
        self.battery = battery
        self.deviceName = deviceName
        self.deviceOsVersion = deviceOsVersion
        self.UDID = UDID
        self.deviceModel = deviceModel
        self.resolution = resolution
        self.appleId = appleId
    }
    
    private(set) var carrier_region = ""
    private(set) var os = ""
    private(set) var battery: Float = -1.0
    private(set) var deviceOsVersion = ""
    private(set) var deviceName = ""
    private(set) var UDID = ""
    private(set) var deviceModel = ""
    private(set) var resolution = ""
    private(set) var appleId = ""
    
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
