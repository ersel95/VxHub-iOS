//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

@preconcurrency import Foundation
@preconcurrency import UIKit
@preconcurrency import KeychainSwift

public struct VxDeviceConfig: @unchecked Sendable {
    
    public init(
        carrier_region: String,
        os: String,
        battery: Float,
        deviceOsVersion: String,
        deviceName: String,
        UDID: String,
        deviceModel: String,
        resolution: String,
        appleId: String,
        idfaStatus: String,
        userType: String = "regular",
        devicePlatform: String = "IOS",
        deviceType: String = "phone",
        deviceBrand: String = "Apple",
        deviceCountry: String = Locale.current.region?.identifier ?? "xx",
        op_region: String = Locale.current.region?.identifier ?? "xx",
        timeZone: String = TimeZone.current.abbreviation() ?? "",
        installedApps: [String: Bool] = [:]
    ) {
        self.carrier_region = carrier_region
        self.os = os
        self.battery = battery
        self.deviceOsVersion = deviceOsVersion
        self.deviceName = deviceName
        self.UDID = UDID
        self.deviceModel = deviceModel
        self.resolution = resolution
        self.appleId = appleId
        self.idfaStatus = idfaStatus
        self.userType = userType
        self.devicePlatform = devicePlatform
        self.deviceType = deviceType
        self.deviceBrand = deviceBrand
        self.deviceCountry = deviceCountry
        self.op_region = op_region
        self.timeZone = timeZone
        self.installedApps = installedApps
    }
    
    // Private(set) properties
    public private(set) var carrier_region: String
    public private(set) var os: String
    public private(set) var battery: Float
    public private(set) var deviceOsVersion: String
    public private(set) var deviceName: String
    public var UDID: String
    public private(set) var deviceModel: String
    public private(set) var resolution: String
    public private(set) var appleId: String
    public private(set) var idfaStatus: String

    // Default properties
    public var userType: String
    public var devicePlatform: String
    public var deviceType: String
    public var deviceBrand: String
    public var deviceCountry: String
    public var deviceLang: String {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en-EN"
        let languageCode = String(preferredLanguage.split(separator: "-").first ?? "en")
        return UserDefaults.VxHub_prefferedLanguage ?? languageCode
    }
    public var op_region: String
    public var timeZone: String
    public var installedApps: [String: Bool]
}
