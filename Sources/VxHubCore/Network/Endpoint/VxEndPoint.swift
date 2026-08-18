//
//  VxEndPoint.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation


internal enum VxHubApi: @unchecked Sendable {
    case deviceRegister
    case validatePurchase(transactionId: String)
    case usePromoCode(promoCode: String)
    case socialLogin(provider: String, token: String, accountId: String, name: String?, email: String?)
    case getProducts
    case sendConversationInfo(conversionInfo: [AnyHashable : Any])
    case getTickets
    case createNewTicket(category: String, message: String)
    case getTicketMessages(ticketId: String)
    case createNewMessage(ticketId: String, message: String)
    case approveQrLogin(token: String)
    case deleteDevice
    case getTicketsUnseenStatus
    case claimRetentionCoin
    case getAppStoreVersion
    case afterPurchaseCheck(transactionId: String, productId: String)
    case sessionEvents(body: [String: Any])
    case sessionStart(body: [String: Any])
    case sessionEnd(body: [String: Any])

    // MARK: - Account authentication
    case authConfig
    case authRegister(email: String, password: String, name: String?)
    case authLogin(email: String, password: String)
    case authSocialLogin(provider: String, token: String, accountId: String?, name: String?, email: String?)
    case authRefresh(refreshToken: String)
    case authLogout(refreshToken: String?)
    case authForgotPassword(email: String)
    case authResetPassword(email: String, code: String, newPassword: String)
    case authVerifyEmail(code: String)
    case authResendVerification
    case authChangePassword(current: String, new: String)
    case authMe
    case authUpdateProfile(name: String?, profilePicture: String?)
    case authDeleteAccount
}

extension VxHubApi: EndPointType {
    
    var baseURLString: String {
        switch self {
        case .getAppStoreVersion:
            let bundleId = Bundle.main.bundleIdentifier ?? ""
            return "https://itunes.apple.com/lookup?bundleId=\(bundleId)"
        default:
            let config = VxBuildConfigs()
            guard let apiUrl = config.value(for: .api) else {
                VxLogger.shared.error("API base URL not found in build config")
                return ""
            }
            return apiUrl
        }
    }

    var baseURL: URL {
        guard let url = URL(string: baseURLString), !baseURLString.isEmpty else {
            VxLogger.shared.error("baseURL could not be configured from: \(baseURLString)")
            return URL(string: "https://invalid.vxhub.local")!
        }
        return url
    }
    
    var path: String {
        switch self {
        case .deviceRegister:
            return "device/register"
        case .validatePurchase:
            return "rc/validate"
        case .usePromoCode:
            return "promo-codes/use"
        case .socialLogin:
            return "device/social-login"
        case .getProducts:
            return "product/app"
        case .sendConversationInfo:
            return "device/conversion"
        case .getTickets:
            return "support/tickets"
        case .createNewTicket:
            return "support/tickets"
        case .getTicketMessages(let ticketId):
            return "support/tickets/\(ticketId)"
        case .createNewMessage(let ticketId, _):
            return "support/tickets/\(ticketId)/messages"
        case .getTicketsUnseenStatus:
            return "support/unseen"
        case .approveQrLogin:
            return "device/qr-login/approve"
        case .deleteDevice:
            return "device"
        case .claimRetentionCoin:
            return "device/retention/claim"
        case .getAppStoreVersion:
             return ""
        case .afterPurchaseCheck:
            return "device/after-purchase"
        case .sessionEvents:
            return "session-analytics/events"
        case .sessionStart:
            return "session-analytics/session/start"
        case .sessionEnd:
            return "session-analytics/session/end"
        case .authConfig:
            return "app-auth/config"
        case .authRegister:
            return "app-auth/register"
        case .authLogin:
            return "app-auth/login"
        case .authSocialLogin:
            return "app-auth/social-login"
        case .authRefresh:
            return "app-auth/refresh"
        case .authLogout:
            return "app-auth/logout"
        case .authForgotPassword:
            return "app-auth/forgot-password"
        case .authResetPassword:
            return "app-auth/reset-password"
        case .authVerifyEmail:
            return "app-auth/verify-email"
        case .authResendVerification:
            return "app-auth/resend-verification"
        case .authChangePassword:
            return "app-auth/change-password"
        case .authMe, .authUpdateProfile, .authDeleteAccount:
            return "app-auth/me"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .deviceRegister, .validatePurchase, .socialLogin, .usePromoCode, .sendConversationInfo, .createNewTicket, .createNewMessage, .approveQrLogin, .claimRetentionCoin, .afterPurchaseCheck, .sessionEvents, .sessionStart, .sessionEnd:
            return .post
        case .getProducts, .getTickets, .getTicketMessages, .getTicketsUnseenStatus, .getAppStoreVersion:
            return .get
        case .deleteDevice:
            return .delete
        case .authRegister, .authLogin, .authSocialLogin, .authRefresh, .authLogout, .authForgotPassword,
             .authResetPassword, .authVerifyEmail, .authResendVerification, .authChangePassword:
            return .post
        case .authConfig, .authMe:
            return .get
        case .authUpdateProfile:
            return .patch
        case .authDeleteAccount:
            return .delete
        }
    }
    
    /// Endpoints that identify the caller by their account rather than by device.
    private var requiresAccessToken: Bool {
        switch self {
        case .authMe, .authUpdateProfile, .authDeleteAccount, .authVerifyEmail,
             .authResendVerification, .authChangePassword:
            return true
        default:
            return false
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case .getAppStoreVersion:
            return nil
        default:
            let deviceId = VxHub.shared.deviceConfig?.UDID ?? ""
            if deviceId.isEmpty {
                VxLogger.shared.warning("deviceConfig.UDID is empty when building headers")
            }
            var headers: HTTPHeaders = [
                "X-Hub-Id": VxHub.shared.config?.hubId ?? "",
                "X-Hub-Device-Id": deviceId
            ]
            if let vId = VxHub.shared.deviceInfo?.vid {
                headers["X-Hub-Vid"] = vId
            }
            // The device language decides which language a verification or reset
            // email is written in.
            if let language = VxHub.shared.deviceConfig?.deviceLang {
                headers["X-Language-Code"] = language
            }
            if requiresAccessToken, let token = VxHub.shared.currentAccessToken {
                headers["Authorization"] = "Bearer \(token)"
            }
            return headers
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getProducts, .getTickets, .getTicketMessages, .deleteDevice, .getTicketsUnseenStatus, .claimRetentionCoin, .getAppStoreVersion:
            return .requestParametersAndHeaders(bodyParameters: .none, bodyEncoding: .urlEncoding, urlParameters: .none, additionHeaders: headers)
        case .deviceRegister:
            guard let deviceConfig = VxHub.shared.deviceConfig else {
                VxLogger.shared.error("deviceConfig is nil during device register request")
                return .requestParametersAndHeaders(bodyParameters: .none, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
            }
            #if os(iOS)
            let idfaValue = VxPermissionManager().getIDFA() ?? ""
            #else
            let idfaValue = ""
            #endif
            var parameters: Parameters = [
                "user_type": deviceConfig.userType,
                "device_platform": deviceConfig.devicePlatform,
                "device_type": deviceConfig.deviceType,
                "device_brand": deviceConfig.deviceBrand,
                "device_model": deviceConfig.deviceModel,
                "country_code": deviceConfig.deviceCountry,
                "language_code": deviceConfig.deviceLang,
                "idfa": idfaValue,
                "appsflyer_id": VxHub.shared.getAppsflyerUUID,
                "op_region": deviceConfig.op_region,
                "carrier_region": deviceConfig.carrier_region,
                "os": deviceConfig.os,
                "resolution": deviceConfig.resolution,
                "one_signal_token": VxHub.shared.getOneSignalPlayerToken,
                "one_signal_player_id": VxHub.shared.getOneSignalPlayerId,
                "apns_token": VxHub.shared.getAPNsToken,
                "startup_time_ms": VxHub.shared.startupTimeMs ?? 0,
                "installed_apps": deviceConfig.installedApps
            ]
            parameters["firebase_id"] = VxProviderRegistry.shared.firebaseProvider?.appInstanceId
            
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .validatePurchase(let transactionId):
            let parameters : [String: Any] = [
                "transactionId": transactionId
            ]
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .usePromoCode(let promoCode):
            let parameters : [String: Any] = [
                "code": promoCode
            ]
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .socialLogin(let provider, let token, let accountId, let name, let email):
            let parameters: [String: Any] = [
                "provider": provider,
                "token": token,
                "account_id": accountId,
                "name": name ?? "",
                "email": email ?? "",
            ]
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .sendConversationInfo(conversionInfo: let info):
            let parameters = Dictionary(uniqueKeysWithValues: info.map {
                (($0.key as? String) ?? "vx_unkwn_type", $0.value)
            })
            return .requestParametersAndHeaders(bodyParameters: parameters,
                                              bodyEncoding: .jsonEncoding,
                                              urlParameters: .none,
                                              additionHeaders: headers)
        case .createNewTicket(let category, let message):
            let parameters : [String: Any] = [
                "category": category,
                "message": message
            ]
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
            
        case .createNewMessage(_, let message):
            let parameters : [String: Any] = [
                "message": message
            ]
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .approveQrLogin(let token):
            let params: [String: String] = [
                "token": token
            ]
            return .requestParametersAndHeaders(bodyParameters: params, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .afterPurchaseCheck(let transactionId, let productId):
            let params: [String: String] = [
                "transaction_id": transactionId,
                "product_id": productId
            ]
            return .requestParametersAndHeaders(bodyParameters:params, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .sessionEvents(let body), .sessionStart(let body), .sessionEnd(let body):
            return .requestParametersAndHeaders(bodyParameters: body, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)

        // MARK: - Account authentication
        case .authConfig, .authMe, .authResendVerification, .authDeleteAccount:
            return .requestParametersAndHeaders(bodyParameters: .none, bodyEncoding: .urlEncoding, urlParameters: .none, additionHeaders: headers)
        case .authRegister(let email, let password, let name):
            var parameters: Parameters = ["email": email, "password": password]
            if let name, !name.isEmpty { parameters["name"] = name }
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .authLogin(let email, let password):
            return .requestParametersAndHeaders(bodyParameters: ["email": email, "password": password], bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .authSocialLogin(let provider, let token, let accountId, let name, let email):
            var parameters: Parameters = ["provider": provider, "token": token]
            if let accountId, !accountId.isEmpty { parameters["account_id"] = accountId }
            if let name, !name.isEmpty { parameters["name"] = name }
            if let email, !email.isEmpty { parameters["email"] = email }
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .authRefresh(let refreshToken):
            return .requestParametersAndHeaders(bodyParameters: ["refresh_token": refreshToken], bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .authLogout(let refreshToken):
            var parameters: Parameters = [:]
            if let refreshToken { parameters["refresh_token"] = refreshToken }
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .authForgotPassword(let email):
            return .requestParametersAndHeaders(bodyParameters: ["email": email], bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .authResetPassword(let email, let code, let newPassword):
            return .requestParametersAndHeaders(bodyParameters: ["email": email, "code": code, "new_password": newPassword], bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .authVerifyEmail(let code):
            return .requestParametersAndHeaders(bodyParameters: ["code": code], bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .authChangePassword(let current, let new):
            return .requestParametersAndHeaders(bodyParameters: ["current_password": current, "new_password": new], bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .authUpdateProfile(let name, let profilePicture):
            var parameters: Parameters = [:]
            if let name { parameters["name"] = name }
            if let profilePicture { parameters["profile_picture"] = profilePicture }
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        }
    }
}
