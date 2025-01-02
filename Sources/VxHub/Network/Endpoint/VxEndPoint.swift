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
           "X-Hub-Device-Id": VxDeviceConfig.shared.UDID
        ]
    }
    
    var task: HTTPTask {
        switch self {
        case .deviceRegister:
            var parameters: Parameters = [
                "user_type": VxDeviceConfig.shared.userType,
                "device_platform": VxDeviceConfig.shared.devicePlatform,
                "device_type": VxDeviceConfig.shared.deviceType,
                "device_brand": VxDeviceConfig.shared.deviceBrand,
                "device_model": VxDeviceConfig.shared.deviceModel,
                "country_code": VxDeviceConfig.shared.deviceCountry,
                "language_code": VxDeviceConfig.shared.deviceLang,
                "idfa": VxPermissionManager.shared.getIDFA() ?? "",
                "appsflyer_id": VxHub.shared.getAppsflyerUUID,
                "op_region": VxDeviceConfig.shared.op_region,
                "carrier_region": VxDeviceConfig.shared.carrier_region,
                "os": VxDeviceConfig.shared.os,
                "resolution": VxDeviceConfig.shared.resolution,
                "one_signal_token": VxHub.shared.getOneSignalPlayerToken,
                "one_signal_player_id": VxHub.shared.getOneSignalPlayerId
            ]
            
            
            parameters["firebase_id"] = VxFirebaseManager.shared.appInstanceId
            
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .validatePurchase(let transactionId):
            let parameters : [String: Any] = [
                "transactionId": transactionId
            ]
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        }
    }
    
}
