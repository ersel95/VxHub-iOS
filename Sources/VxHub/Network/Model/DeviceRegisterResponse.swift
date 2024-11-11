//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation

internal struct DeviceRegisterResponse: Codable, Sendable {
    let status: String?
    let message: String?
    let vid: String?
    let device: DeviceProfile?
    let config: ApplicationConfig?
    let thirdParty: ThirdPartyInfo?

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case vid
        case device
        case config
        case thirdParty = "third_party"
    }
}

struct DeviceProfile: Codable, Sendable {
    let premiumStatus: Bool?
    let banStatus: Bool?
    let userType: String?
    let onesignalStatus: Bool?

    enum CodingKeys: String, CodingKey {
        case premiumStatus = "premium_status"
        case banStatus = "ban_status"
        case userType = "user_type"
        case onesignalStatus = "onesignal_status"
    }
}

struct ApplicationConfig: Codable, Sendable {
    let storeVersion: String?
    let forceUpdate: Bool?
    let localizationUrl: String?
    let supportEmail: String?
    let supportedLanguages: [String]?
    let eulaUrl: String?
    let privacyUrl: String?

    enum CodingKeys: String, CodingKey {
        case storeVersion = "store_version"
        case forceUpdate = "force_update"
        case localizationUrl = "localization_url"
        case supportEmail = "support_email"
        case supportedLanguages = "supported_languages"
        case eulaUrl = "tos_url"
        case privacyUrl = "privacy_policy_url"
    }
}

struct ThirdPartyInfo: Codable, Sendable {
    let revenueCatId: String?
    let appsflyerDevKey: String?
    let appsflyerAppId: String?
    let onesignalAppId: String?
    var oneSignalPlayerToken: String?
    var oneSignalPlayerId: String?
    let amplitudeApiKey: String?
    let firebaseConfigUrl: String?

    enum CodingKeys: String, CodingKey {
        case revenueCatId = "revenue_cat_id"
        case appsflyerDevKey = "appsflyer_dev_key"
        case appsflyerAppId = "appsflyer_app_id"
        case onesignalAppId = "onesignal_app_id"
        case amplitudeApiKey = "amplitude_api_key"
        case firebaseConfigUrl = "info_plist_url"
    }
}

struct DeviceData: Codable, Sendable {
    let vid: String?
    let device: DeviceProfile?
    let config: ApplicationConfig?
    let thirdParty: ThirdPartyInfo?

    enum CodingKeys: String, CodingKey {
        case vid
        case device
        case config
        case thirdParty = "third_party"
    }
}
