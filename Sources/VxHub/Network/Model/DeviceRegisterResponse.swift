//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation

public struct DeviceRegisterResponse: Codable, Sendable {
    let status: String?
    let message: String?
    let vid: String?
    let device: DeviceProfile?
    let config: ApplicationConfig?
    let thirdParty: ThirdPartyInfo?
    let support: SupportInfo?

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case vid
        case device
        case config
        case thirdParty = "third_party"
        case support
    }
}

public struct DeviceProfile: Codable, Sendable {
    internal let premiumStatus: Bool?
    public let banStatus: Bool?
    public let userType: String?
    public let onesignalStatus: Bool?

    enum CodingKeys: String, CodingKey {
        case premiumStatus = "premium_status"
        case banStatus = "ban_status"
        case userType = "user_type"
        case onesignalStatus = "onesignal_status"
    }
}

public struct ApplicationConfig: Codable, Sendable {
    public let storeVersion: String?
    public let forceUpdate: Bool?
    public let localizationUrl: String?
    public let supportEmail: String?
    public let supportedLanguages: [String]?
    public let eulaUrl: String?
    public let privacyUrl: String?

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

public struct ThirdPartyInfo: Codable, Sendable {
    let revenueCatId: String?
    let appsflyerDevKey: String?
    let appsflyerAppId: String?
    let onesignalAppId: String?
    var oneSignalPlayerToken: String?
    var oneSignalPlayerId: String?
    let amplitudeApiKey: String?
    let amplitudeDeploymentKey: String?
    let firebaseConfigUrl: String?
    let facebookAppId: String?
    let facebookClientToken: String?
    let facebookApplicationName: String?
    let appStoreAppId: String?
    let sentryDsn: String?
    let googleClientKey: String?

    enum CodingKeys: String, CodingKey {
        case revenueCatId = "revenue_cat_api_key"
        case appsflyerDevKey = "appsflyer_dev_key"
        case appsflyerAppId = "appsflyer_app_id"
        case onesignalAppId = "one_signal_api_key" //TODO: - BE SHOULD CHANGE THE CODING KEY
        case amplitudeApiKey = "amplitude_api_key"
        case amplitudeDeploymentKey = "amplitude_deployment_key"
        case firebaseConfigUrl = "firebase_plist_url"
        case facebookAppId = "facebook_app_id"
        case facebookClientToken = "facebook_client_token"
        case facebookApplicationName = "facebook_display_name"
        case appStoreAppId = "app_store_app_id"
        case sentryDsn = "sentry_dsn"
        case googleClientKey = "google_client_id"
    }
}

public struct SupportInfo: Codable, Sendable {
    let unseenResponse: Bool?
    let categories: [String]
    
    enum CodingKeys: String, CodingKey {
        case unseenResponse = "unseen_response"
        case categories
    }
}

public struct DeviceData: Codable, Sendable {
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
