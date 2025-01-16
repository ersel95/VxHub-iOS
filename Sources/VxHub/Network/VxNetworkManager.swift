//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation

fileprivate enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

fileprivate enum Result<String>{
    case success
    case failure(String)
}

internal class VxNetworkManager : @unchecked Sendable {
    let router = Router<VxHubApi>()

    public init() {}
    
    func registerDevice(completion: @escaping @Sendable (_ response: DeviceRegisterResponse?, [String: any Sendable]?, _ error: String?) -> Void) {
        router.request(.deviceRegister) { data, response, error in
            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                completion(nil, nil, "VxLog: Please check your network connection. \(String(describing:error))")
            }
            
            if let response = response as? HTTPURLResponse {
                VxLogger.shared.info("Device register response: \(response.statusCode)")
                debugPrint("Device register response: \(response.statusCode)")
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        var remoteConfig: [String: any Sendable]? = nil
                        let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: [])
                        
                        if let jsonDict = jsonObject as? [String: Any] {
                            if let remoteConfigData = jsonDict["remote_config"] {
                                remoteConfig = remoteConfigData as? [String: any Sendable]
                            }
                            
                            let apiResponse = try decoder.decode(DeviceRegisterResponse.self, from: responseData)
                            VxHub.shared.configureRegisterResponse(apiResponse, remoteConfig ?? [:])
                            completion(apiResponse, remoteConfig, nil)
                        } else {
                            completion(nil, nil, NetworkResponse.unableToDecode.rawValue)
                        }
                    } catch {
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(nil, nil, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                case .failure(let networkFailureError):
                    completion(nil, nil, networkFailureError)
                }
            }
        }
    }
    
    func validatePurchase(transactionId: String) {
        router.request(.validatePurchase(transactionId: transactionId)) { _, _, _ in }
    }

    func signInRequest(provider: String, token: String, completion: @escaping @Sendable (Bool, Error?) -> Void) {
        router.request(.signInWithGoogle(provider: provider, token: token)) { data, response, error in
            if let response = response as? HTTPURLResponse {
                VxLogger.shared.info("Sign in with Google response: \(response.statusCode)")
                if response.statusCode == 200 || response.statusCode ==  201 { //TODO: - Change later
                    completion(true, nil)
                }  else {
                    completion(false, nil)
                }
            }
        }
    }
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        switch response.statusCode {
        case 200...299:
            return .success
        case 400:
            VxLogger.shared.warning(NetworkResponse.badRequest.rawValue)
            return .failure(NetworkResponse.badRequest.rawValue)
        case 401...499:
            VxLogger.shared.warning(NetworkResponse.authenticationError.rawValue)
            return .failure(NetworkResponse.authenticationError.rawValue)
        case 500...599:
            VxLogger.shared.warning(NetworkResponse.badRequest.rawValue)
            return .failure(NetworkResponse.badRequest.rawValue)
        case 600:
            VxLogger.shared.warning(NetworkResponse.outdated.rawValue)
            return .failure(NetworkResponse.outdated.rawValue)
        default:
            VxLogger.shared.error(NetworkResponse.failed.rawValue)
            return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
