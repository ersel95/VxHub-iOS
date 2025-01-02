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
}

extension VxHubApi: EndPointType {
    
    var baseURLString: String {
        switch VxHub.shared.config?.environment {
        case .stage: return "https://stage.api.volvoxhub.com/api/v1/" //TODO: Add to build config
        case .prod: return "https://api.volvoxhub.com/api/v1/"        //TODO: Add to build config
        default: return ""
        }
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
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .deviceRegister, .validatePurchase:
            return .post
        }
    }
    
    var headers: HTTPHeaders? {
        return [
           "X-Hub-Id": VxHub.shared.config?.hubId ?? "",
           "X-Hub-Device-Id": VxHub.shared.deviceConfig!.UDID
        ]
    }
    
    var task: HTTPTask {
        switch self {
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
        }
    }
    
}
