//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation

fileprivate enum NetworkResponse:String { //TODO: - Add logger
    case success
    case authenticationError = "VxLog: You need to be authenticated first."
    case badRequest = "VxLog: Bad request"
    case outdated = "VxLog: The url you requested is outdated."
    case failed = "VxLog: Network request failed."
    case noData = "VxLog: Response returned with no data to decode."
    case unableToDecode = "VxLog: We could not decode the response."
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
        router.request(.deviceRegister) { data, response, error in
            if error != nil {
                completion(nil, "VxLog: Please check your network connection. \(String(describing:error))")  //TODO: - Add logger
            }
            
            if let response = response as? HTTPURLResponse {
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
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
