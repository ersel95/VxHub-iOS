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
    let remoteConfig: RemoteConfig?

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case vid
        case device
        case config
        case thirdParty = "third_party"
        case remoteConfig = "remote_config"
    }
}

public struct RemoteConfig : Codable, Sendable {
    let bloxOnboardingAssetUrls: String?
    let bloxSetupUrl: String?
    let bloxSetupTexts: String?
    public let showLanding: String?
    
    enum CodingKeys: String, CodingKey, Codable {
        case bloxOnboardingAssetUrls = "blox_setup_screens"
        case bloxSetupUrl = "blox_setup_url"
        case bloxSetupTexts = "blox_setup_texts"
        case showLanding = "landing_show"
    }
}

public struct DeviceProfile: Codable, Sendable {
    public let premiumStatus: Bool?
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

    enum CodingKeys: String, CodingKey {
        case revenueCatId = "revenue_cat_id"
        case appsflyerDevKey = "appsflyer_dev_key"
        case appsflyerAppId = "appsflyer_app_id"
        case onesignalAppId = "onesignal_app_id"
        case amplitudeApiKey = "amplitude_api_key"
        case amplitudeDeploymentKey = "amplitude_deployment_key"
        case firebaseConfigUrl = "firebase_plist_url"
        case facebookAppId = "facebook_app_id"
        case facebookClientToken = "facebook_client_token"
        case facebookApplicationName = "application_name"
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
