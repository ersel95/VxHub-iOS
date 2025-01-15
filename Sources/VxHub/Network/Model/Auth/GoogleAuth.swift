//
//  File.swift
//  VxHub
//
//  Created by furkan on 13.01.2025.
//

//
//internal struct GoogleAuthResponse: Codable, Sendable {
//    let status: String
//    let message: String
//    let vid: String
//    let device: GoogleAuthDevice
//    let config: GoogleAuthConfig
//    let thirdParty: GoogleAuthThirdParty
//    let remoteConfig: [String: Any]
//    
//    enum CodingKeys: String, CodingKey {
//        case status
//        case message
//        case vid
//        case device
//        case config
//        case thirdParty = "third_party"
//        case remoteConfig = "remote_config"
//    }
//}
//
//internal struct GoogleAuthDevice: Codable, Sendable {
//    let premiumStatus: Bool
//    let banStatus: Bool
//    let userType: String
//    let oneSignalStatus: Bool
//    
//    enum CodingKeys: String, CodingKey {
//        case premiumStatus = "premium_status"
//        case banStatus = "ban_status"
//        case userType = "user_type"
//        case oneSignalStatus = "one_signal_status"
//    }
//}
//
//internal struct GoogleAuthConfig: Codable, Sendable {
//    let storeVersion: String
//    let forceUpdate: Bool
//    let localizationUrl: String
//    let supportEmail: String
//    let supportedLanguages: [String]
//    let tosUrl: String
//    let privacyPolicyUrl: String
//    
//    enum CodingKeys: String, CodingKey {
//        case storeVersion = "store_version"
//        case forceUpdate = "force_update"
//        case localizationUrl = "localization_url"
//        case supportEmail = "support_email"
//        case supportedLanguages = "supported_languages"
//        case tosUrl = "tos_url"
//        case privacyPolicyUrl = "privacy_policy_url"
//    }
//}
//
//internal struct GoogleAuthThirdParty: Codable, Sendable {
//    let revenueCatApiKey: String
//    let appsflyerDevKey: String
//    let appsflyerAppId: String
//    let oneSignalApiKey: String
//    let amplitudeApiKey: String
//    let facebookAppId: String?
//    let facebookClientToken: String?
//    let facebookDisplayName: String?
//    let firebasePlistUrl: String
//    let amplitudeDeploymentKey: String?
//    let appStoreAppId: String
//    let sentryDsn: String
//    
//    enum CodingKeys: String, CodingKey {
//        case revenueCatApiKey = "revenue_cat_api_key"
//        case appsflyerDevKey = "appsflyer_dev_key"
//        case appsflyerAppId = "appsflyer_app_id"
//        case oneSignalApiKey = "one_signal_api_key"
//        case amplitudeApiKey = "amplitude_api_key"
//        case facebookAppId = "facebook_app_id"
//        case facebookClientToken = "facebook_client_token"
//        case facebookDisplayName = "facebook_display_name"
//        case firebasePlistUrl = "firebase_plist_url"
//        case amplitudeDeploymentKey = "amplitude_deployment_key"
//        case appStoreAppId = "app_store_app_id"
//        case sentryDsn = "sentry_dsn"
//    }
//}
