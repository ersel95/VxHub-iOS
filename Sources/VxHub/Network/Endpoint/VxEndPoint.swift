//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation


internal enum VxHubApi {
    case deviceRegister
    case validatePurchase(transactionId: String)
    case usePromoCode(promoCode: String)
    case signInWithGoogle(provider: String, token: String)
    case getProducts
}

extension VxHubApi: EndPointType {
    
    var baseURLString: String {
        let config = VxBuildConfigs()
        let value = config.value(for: .api)!
        return value
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
        case .signInWithGoogle:
            return "rc/signinwithgoogle"
        case .getProducts:
            return "product/app"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .deviceRegister, .validatePurchase, .signInWithGoogle, .usePromoCode:
            return .post
        case .getProducts:
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
        case .getProducts:
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
                "one_signal_player_id": VxHub.shared.getOneSignalPlayerId
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
        case .signInWithGoogle(let provider, let token):
            let parameters : [String: Any] = [
                "provider": provider,
                "token": token
            ]
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        }
    }
    
}
