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
    case socialLogin(provider: String, token: String, accountId: String)
    case getProducts
    case sendConversationInfo(conversionInfo: [AnyHashable : Any])
    case getTickets
    case createNewTicket(category: String, message: String)
    case getTicketMessages(ticketId: String)
    case createNewMessage(ticketId: String, message: String)
}

extension VxHubApi: EndPointType {
    
    var baseURLString: String {
        let config = VxBuildConfigs()
        let value = config.value(for: .api)!
        return "http://10.81.76.46:3001/api/v1/"
    }
    
    var baseURL: URL {
        guard let url = URL(string: baseURLString) else { fatalError("baseURL could not be configured.")}
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
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .deviceRegister, .validatePurchase, .socialLogin, .usePromoCode, .sendConversationInfo, .createNewTicket, .createNewMessage:
            return .post
        case .getProducts, .getTickets, .getTicketMessages:
            return .get
        }
    }
    
    var headers: HTTPHeaders? {
        if let vId = VxHub.shared.deviceInfo?.vid {
            return [
               "X-Hub-Id": VxHub.shared.config?.hubId ?? "",
               "X-Hub-Device-Id": VxHub.shared.deviceConfig!.UDID,
               "X-Hub-Vid": vId
            ]
        }else{
            return [
               "X-Hub-Id": VxHub.shared.config?.hubId ?? "",
               "X-Hub-Device-Id": VxHub.shared.deviceConfig!.UDID
            ]
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getProducts, .getTickets, .getTicketMessages:
            return .requestParametersAndHeaders(bodyParameters: .none, bodyEncoding: .urlEncoding, urlParameters: .none, additionHeaders: headers)
        case .deviceRegister:
            let deviceConfig = VxHub.shared.deviceConfig!
            var parameters: Parameters = [
                "user_type": deviceConfig.userType,
                "device_platform": deviceConfig.devicePlatform,
                "device_type": deviceConfig.deviceType,
                "device_brand": deviceConfig.deviceBrand,
                "device_model": deviceConfig.deviceModel,
                "country_code": deviceConfig.deviceCountry,
                "language_code": deviceConfig.deviceLang,
                "idfa": VxPermissionManager().getIDFA() ?? "",
                "appsflyer_id": VxHub.shared.getAppsflyerUUID,
                "op_region": deviceConfig.op_region,
                "carrier_region": deviceConfig.carrier_region,
                "os": deviceConfig.os,
                "resolution": deviceConfig.resolution,
                "one_signal_token": VxHub.shared.getOneSignalPlayerToken,
                "one_signal_player_id": VxHub.shared.getOneSignalPlayerId,
                "installed_apps": deviceConfig.installedApps
            ]
            parameters["firebase_id"] = VxFirebaseManager().appInstanceId
            
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
        case .socialLogin(let provider, let token, let accountId):
            let parameters: [String: Any] = [
                "provider": provider,
                "token": token,
                "account_id": accountId
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
        }
    }
    
}
