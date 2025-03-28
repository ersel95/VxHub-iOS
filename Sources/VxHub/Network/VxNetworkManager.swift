//
//  VxNetworkManager.swift
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

fileprivate enum NetworkResult<String>{
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
                return
            }
            
            if let response = response as? HTTPURLResponse {
                VxLogger.shared.info("Device register response: \(response.statusCode)")
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

    func signInRequest(provider: String, token: String, accountId: String, name: String?, email: String?, completion: @escaping @Sendable (_ response: DeviceRegisterResponse?, _ error: String?) -> Void) {
        router.request(.socialLogin(provider: provider, token: token, accountId: accountId, name: name, email: email)) { data, response, error in
            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                completion(nil, "VxLog: Please check your network connection. \(String(describing:error))")
            }
            
            if let response = response as? HTTPURLResponse {
                VxLogger.shared.info("Social Login response: \(response.statusCode)")
                
                if let responseData = data, let jsonString = String(data: responseData, encoding: .utf8) {
                    VxLogger.shared.info("Raw JSON response: \(jsonString)")
                } else {
                    VxLogger.shared.warning("No data received or unable to convert to UTF-8 string")
                }
                
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
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
                            VxLogger.shared.success("Decoding apiResponse: \(apiResponse)")

                            VxHub.shared.configureRegisterResponse(apiResponse, remoteConfig ?? [:])
                            completion(apiResponse, nil)
                        } else {
                            completion(nil, NetworkResponse.unableToDecode.rawValue)
                        }
                    } catch {
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
        
    func validatePromoCode(code: String, completion: @escaping @Sendable (VxPromoCode) -> Void) {
        router.request(.usePromoCode(promoCode: code)) { data, response, error in
            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                completion(VxPromoCode(error: VxPromoCodeErrorResponse(message: ["Please check your network connection"])))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                VxLogger.shared.info("Promo code validation response: \(response.statusCode)")
                
                guard let responseData = data else {
                    completion(VxPromoCode(error: VxPromoCodeErrorResponse(message: [NetworkResponse.noData.rawValue])))
                    return
                }
                                
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    do {
                        let successResponse = try JSONDecoder().decode(VxPromoCodeSuccessResponse.self, from: responseData)
                        guard successResponse.success == true else {
                            completion(VxPromoCode(error: VxPromoCodeErrorResponse(message: ["Network Request is returned failed"])))
                            return
                        }
                        
                        let actionType: VxPromoCodeActionTypes = VxPromoCodeActionTypes(rawValue: successResponse.actionType ?? "premium") ?? .premium
                        let actionMeta: VxPromoCodeActionMeta = VxPromoCodeActionMeta(data: successResponse.actionMeta,
                                                                                      actionType: actionType)
                        
                        let promoData: VxPromoCodeData = VxPromoCodeData(actionType: actionType,
                                                                         actionMeta: actionMeta,
                                                                         extraData: successResponse.extraData)
                        
                        completion(VxPromoCode(data: promoData))
                        return
                        
                    } catch {
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(VxPromoCode(error: VxPromoCodeErrorResponse(message: ["Decoding failed with error: \(error)"])))
                        return
                    }
                case .failure(_):
                    do {
                        let errorResponse = try JSONDecoder().decode(VxPromoCodeErrorResponse.self, from: responseData)
                        completion(VxPromoCode(error: VxPromoCodeErrorResponse(message: errorResponse.message ?? ["Unknown error"])))
                        return
                    } catch {
                        completion(VxPromoCode(error: VxPromoCodeErrorResponse(message: ["Decoding failed with error: \(error)"])))
                        return
                    }
                }
            }
        }
    }
    
    func getProducts(completion: @escaping @Sendable ([VxGetProductsResponse]?) -> Void) {
        router.request(.getProducts) { data, response, error in
            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                completion(nil)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    do {
                        guard let data else {
                            completion(nil)
                            return }
                        let successResponse = try JSONDecoder().decode([VxGetProductsResponse].self, from: data)
                        completion(successResponse)
                    } catch {
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(nil)
                    }
                case .failure(_):
                    completion(nil)
                    //                    completion(false, NSError(domain: "VxHub", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: networkError]))
                }
            }
        }
    }
    
    func getTickets(completion: @escaping @Sendable ([VxGetTicketsResponse]?) -> Void) {
        router.request(.getTickets) { data, response, error in
            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                completion(nil)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    do {
                        guard let data else {
                            completion(nil)
                            return
                        }
                        let successResponse = try JSONDecoder().decode([VxGetTicketsResponse].self, from: data)
                        completion(successResponse)
                    } catch {
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(nil)
                    }
                case .failure(_):
                    completion(nil)
                }
            }
        }
    }
    
    func createNewTicket(category: String, message: String, completion: @escaping @Sendable (VxCreateTicketSuccessResponse?) -> Void) {
        router.request(.createNewTicket(category: category, message: message)) { data, response, error in
            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                completion(nil)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    do {
                        guard let data else {
                            completion(nil)
                            return
                        }
                        let successResponse = try JSONDecoder().decode(VxCreateTicketSuccessResponse.self, from: data)
                        completion(successResponse)
                    } catch {
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(nil)
                    }
                case .failure(_):
                    completion(nil)
                }
            }
        }
    }
    
    func createNewMessage(ticketId: String, message: String, completion: @escaping @Sendable (Message?) -> Void) {
        router.request(.createNewMessage(ticketId: ticketId, message: message)) { data, response, error in
            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                completion(nil)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    do {
                        guard let data else {
                            completion(nil)
                            return
                        }
                        let successResponse = try JSONDecoder().decode(Message.self, from: data)
                        completion(successResponse)
                    } catch {
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(nil)
                    }
                case .failure(_):
                    completion(nil)
                }
            }
        }
    }

    func sendConversationData(_ conversionInfo : [AnyHashable: Any]) {
        router.request(.sendConversationInfo(conversionInfo: conversionInfo)) { _, res, _ in }
    }
    
    func getTicketMessagesById(ticketId: String, completion: @escaping @Sendable (VxGetTicketMessagesResponse?) -> Void) {
        router.request(.getTicketMessages(ticketId: ticketId)) { data, response, error in
            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                completion(nil)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    do {
                        guard let data else {
                            completion(nil)
                            return
                        }
                        let successResponse = try JSONDecoder().decode(VxGetTicketMessagesResponse.self, from: data)
                        completion(successResponse)
                    } catch {
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(nil)
                    }
                case .failure(_):
                    completion(nil)
                }
            }
        }
    }
    
    func approveQrCode(token: String, completion: @escaping @Sendable (Bool, String?) -> Void) {
        router.request(.approveQrLogin(token: token)) { data, response, error in
            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                completion(false, "Please check your network connection. \(String(describing: error))")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                VxLogger.shared.info("QR code approval response: \(response.statusCode)")
                let result = self.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(false, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    do {
                        let successResponse = try JSONDecoder().decode(VxApproveQrSuccessResponse.self, from: responseData)
                        if successResponse.success == true {
                            completion(true, nil) // Success case: return true with no message
                        } else {
                            completion(false, "QR approval failed")
                        }
                    } catch {
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(false, "Decoding failed: \(error.localizedDescription)")
                    }
                    
                case .failure(_):
                    guard let responseData = data else {
                        completion(false, "Data is empty.")
                        return
                    }
                    
                    do {
                        let failResponse = try JSONDecoder().decode(VxApproveQrFailResponse.self, from: responseData)
                        let errorMessage = failResponse.message ?? failResponse.error ?? "QR login failed with status: \(failResponse.statusCode ?? response.statusCode)"
                        completion(false, errorMessage)
                    } catch {
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(false, error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func deleteAccount(completion: @escaping @Sendable (Bool, String?) -> Void) {
        router.request(.deleteDevice) { data, response, error in
            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                completion(false, "Please check your network connection. \(String(describing: error))")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                VxLogger.shared.info("Delete account response: \(response.statusCode)")
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(false, NetworkResponse.noData.rawValue)
                        return
                    }

                    do {
                        let successResponse = try JSONDecoder().decode(VxDeleteAccountResponse.self, from: responseData)
                        if successResponse.success == true {
                            completion(true, nil)
                        } else {
                            completion(false, "Delete account failed")
                        }
                    } catch {
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(false, "Decoding failed: \(error.localizedDescription)")
                    }
                case .failure(_):
                    completion(false, error?.localizedDescription)
                }
            }
        }
    }
    
    func getTicketsUnseenStatus(completion: @escaping @Sendable (Bool, String?) -> Void) {
        router.request(.getTicketsUnseenStatus) { data, response, error in
            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                completion(false, "Please check your network connection. \(String(describing: error))")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                VxLogger.shared.info("Unseen status response: \(response.statusCode)")
                let result = self.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(false, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    do {
                        let successResponse = try JSONDecoder().decode(VxGetTicketsUnseenStatusResponse.self, from: responseData)

                        if let status = successResponse.status, status == "success", let unseenResponse = successResponse.unseenResponse {
                            completion(unseenResponse, nil)
                        } else {
                            completion(false, "Unseen status failed")
                        }
                    } catch {
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(false, "Decoding failed: \(error.localizedDescription)")
                    }
                    
                case .failure(_):
                    guard let responseData = data else {
                        completion(false, "Data is empty.")
                        return
                    }
                    
                    do {
                        let failResponse = try JSONDecoder().decode(VxGetTicketsUnseenStatusFailResponse.self, from: responseData)
                        let errorMessage = failResponse.message ?? failResponse.error ?? "Unseen status failed with status: \(failResponse.statusCode ?? response.statusCode)"
                        completion(false, errorMessage)
                    } catch {
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(false, error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func claimRetentionCoinGift(completion: @escaping @Sendable (Result<VxClaimRetentionCoinGiftResponse, VxClaimRetentionCoinGiftFailResponse>) -> Void) {
        router.request(.claimRetentionCoin) { data, response, error in
            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                let networkErrorResponse = VxClaimRetentionCoinGiftFailResponse(message: "Network error", error: error?.localizedDescription, statusCode: nil)
                completion(.failure(networkErrorResponse))
                return
            }
            
            guard let response = response as? HTTPURLResponse, let data else {
                let unknownErrorResponse = VxClaimRetentionCoinGiftFailResponse(message: "Unknown error", error: nil, statusCode: nil)
                completion(.failure(unknownErrorResponse))
                return
            }
            
            let result = self.handleNetworkResponse(response)
            switch result {
            case .success:
                do {
                    let successResponse = try JSONDecoder().decode(VxClaimRetentionCoinGiftResponse.self, from: data)
                    completion(.success(successResponse))
                } catch {
                    VxLogger.shared.error("Decoding failed with error: \(error)")
                    let decodingErrorResponse = VxClaimRetentionCoinGiftFailResponse(message: "Decoding failed", error: error.localizedDescription, statusCode: response.statusCode)
                    completion(.failure(decodingErrorResponse))
                }
            case .failure(let errorMessage):
                do {
                    let failureResponse = try JSONDecoder().decode(VxClaimRetentionCoinGiftFailResponse.self, from: data)
                    completion(.failure(failureResponse))
                } catch {
                    VxLogger.shared.error("Error decoding failure response: \(error)")
                    let fallbackErrorResponse = VxClaimRetentionCoinGiftFailResponse(message: "Unknown failure", error: errorMessage, statusCode: response.statusCode)
                    completion(.failure(fallbackErrorResponse))
                }
            }
        }
    }

    func getAppStoreVersion(completion: @escaping @Sendable (String?) -> Void) {
        debugPrint("Debug: getAppStoreVersion called")

        router.request(.getAppStoreVersion) { data, response, error in
            debugPrint("Debug: bura 1--data--\(data)")
            debugPrint("Debug: bura 1--response--\(response)")
            debugPrint("Debug: bura 1--error--\(error)")

            if error != nil {
                VxLogger.shared.warning("Please check your network connection")
                completion(nil)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    do {
                        guard let data else {
                            debugPrint("Debug: data nil")
                            completion(nil)
                            return
                        }
                        let decodedData = try JSONDecoder().decode(AppStoreResponse.self, from: data)
                        debugPrint("Debug: decodedData--\(decodedData)")

                        let storeVersion = decodedData.results.first?.version
                        debugPrint("Debug: storeVersion--\(storeVersion)")

                        completion(storeVersion)
                    } catch {
                        debugPrint("Debug: Data could not be decoded")
                        VxLogger.shared.error("Decoding failed with error: \(error)")
                        completion(nil)
                    }
                case .failure(_):
                    debugPrint("Debug: failure")
                    completion(nil)
                }
            }
        }
    }

    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> NetworkResult<String> {
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
