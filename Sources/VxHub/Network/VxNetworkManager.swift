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
    public static let shared = VxNetworkManager()
    let router = Router<VxHubApi>()

    private init() {}
    
    func registerDevice(completion: @escaping @Sendable (_ response: DeviceRegisterResponse?, _ error: String?) -> Void) {
        debugPrint("device register geldi 1")
        router.request(.deviceRegister) { data, response, error in
            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                completion(nil, "VxLog: Please check your network connection. \(String(describing:error))")  //TODO: - Add logger
            }
            
            if let response = response as? HTTPURLResponse {
                VxLogger.shared.info("Device register response: \(response.statusCode)")
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return	
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(DeviceRegisterResponse.self, from: responseData)
                        
                        completion(apiResponse,nil)
                    }catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func validatePurchase(transactionId: String) {
        router.request(.validatePurchase(transactionId: transactionId)) { _, _, _ in }
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
