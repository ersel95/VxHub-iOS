//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation

#if canImport(VxHub_Firebase)
import VxHub_Firebase
#endif

@MainActor
internal enum VxHubApi {
    case deviceRegister
    case validatePurchase(transactionId: String)
}

extension VxHubApi: @preconcurrency EndPointType {
    
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
           "X-Hub-Device-Id": VxDeviceConfig.UDID
        ]
    }
    
    var task: HTTPTask {
        switch self {
        case .deviceRegister:
            var parameters: Parameters = [
                "user_type": VxDeviceConfig.userType,
                "device_platform": VxDeviceConfig.devicePlatform,
                "device_type": VxDeviceConfig.deviceType,
                "device_brand": VxDeviceConfig.deviceBrand,
                "device_model": VxDeviceConfig.deviceModel,
                "country_code": VxDeviceConfig.deviceCountry,
                "language_code": VxDeviceConfig.deviceLang,
                "idfa": VxPermissionManager.shared.getIDFA() ?? "",
                "appsflyer_id": VxHub.shared.deviceInfo?.thirdPartyInfos?.appsflyerAppId ?? "",
                "op_region": VxDeviceConfig.op_region,
                "carrier_region": VxDeviceConfig.carrier_region,
                "os": VxDeviceConfig.os,
                "resolution": VxDeviceConfig.resolution,
                "one_signal_token": VxHub.shared.deviceInfo?.thirdPartyInfos?.oneSignalPlayerToken ?? "",
                "one_signal_player_id": VxHub.shared.deviceInfo?.thirdPartyInfos?.oneSignalPlayerId ?? ""
            ]
            
            #if canImport(VxHub_Firebase)
            parameters["firebase_id"] = VxFirebaseManager.shared.appInstanceId
            #endif
            
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        case .validatePurchase(let transactionId):
            let parameters : [String: Any] = [
                "transactionId": transactionId
            ]
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: .none, additionHeaders: headers)
        }
    }
    
}
