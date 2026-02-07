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

    // MARK: - Private async helpers

    private func validateHTTPResponse(_ response: URLResponse) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VxHubError.unknown("Invalid response type")
        }
        let result = handleNetworkResponse(httpResponse)
        switch result {
        case .success:
            return httpResponse
        case .failure(let errorMessage):
            throw VxHubError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }

    private func decodeResponse<T: Decodable>(_ type: T.Type, data: Data, response: URLResponse) throws -> T {
        let httpResponse = try validateHTTPResponse(response)
        guard !data.isEmpty else {
            throw VxHubError.noData
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            VxLogger.shared.error("Decoding failed with error: \(error)")
            throw VxHubError.decodingFailed(underlying: error)
        }
    }

    // MARK: - Register Device (Async)

    func registerDevice() async throws -> (DeviceRegisterResponse, [String: any Sendable]?) {
        let (data, response) = try await router.request(.deviceRegister)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VxHubError.unknown("Invalid response type")
        }

        VxLogger.shared.info("Device register response: \(httpResponse.statusCode)")
        let result = handleNetworkResponse(httpResponse)

        switch result {
        case .success:
            guard !data.isEmpty else {
                throw VxHubError.noData
            }

            let decoder = JSONDecoder()
            var remoteConfig: [String: any Sendable]? = nil
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

            guard let jsonDict = jsonObject as? [String: Any] else {
                throw VxHubError.decodingFailed(underlying: NSError(domain: "VxHub", code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkResponse.unableToDecode.rawValue]))
            }

            if let remoteConfigData = jsonDict["remote_config"] {
                remoteConfig = remoteConfigData as? [String: any Sendable]
            }

            let apiResponse = try decoder.decode(DeviceRegisterResponse.self, from: data)
            await MainActor.run {
                VxHub.shared.configureRegisterResponse(apiResponse, remoteConfig ?? [:])
            }
            return (apiResponse, remoteConfig)

        case .failure(let networkFailureError):
            throw VxHubError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }

    func registerDevice(completion: @escaping @Sendable (_ response: DeviceRegisterResponse?, [String: any Sendable]?, _ error: String?) -> Void) {
        Task {
            do {
                let (response, remoteConfig) = try await registerDevice()
                await MainActor.run {
                    completion(response, remoteConfig, nil)
                }
            } catch {
                VxLogger.shared.warning("Please check your network connection")
                await MainActor.run {
                    completion(nil, nil, "VxLog: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Validate Purchase (fire-and-forget, no async needed)

    func validatePurchase(transactionId: String) {
        router.request(.validatePurchase(transactionId: transactionId)) { _, _, _ in }
    }

    // MARK: - Sign In Request (Async)

    func signInRequest(provider: String, token: String, accountId: String, name: String?, email: String?) async throws -> DeviceRegisterResponse {
        let (data, response) = try await router.request(.socialLogin(provider: provider, token: token, accountId: accountId, name: name, email: email))

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VxHubError.unknown("Invalid response type")
        }

        VxLogger.shared.info("Social Login response: \(httpResponse.statusCode)")

        if let jsonString = String(data: data, encoding: .utf8) {
            VxLogger.shared.info("Raw JSON response: \(jsonString)")
        } else {
            VxLogger.shared.warning("No data received or unable to convert to UTF-8 string")
        }

        let result = handleNetworkResponse(httpResponse)
        switch result {
        case .success:
            guard !data.isEmpty else {
                throw VxHubError.noData
            }

            let decoder = JSONDecoder()
            var remoteConfig: [String: any Sendable]? = nil
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

            guard let jsonDict = jsonObject as? [String: Any] else {
                throw VxHubError.decodingFailed(underlying: NSError(domain: "VxHub", code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkResponse.unableToDecode.rawValue]))
            }

            if let remoteConfigData = jsonDict["remote_config"] {
                remoteConfig = remoteConfigData as? [String: any Sendable]
            }

            let apiResponse = try decoder.decode(DeviceRegisterResponse.self, from: data)
            VxLogger.shared.success("Decoding apiResponse: \(apiResponse)")
            await MainActor.run {
                VxHub.shared.configureRegisterResponse(apiResponse, remoteConfig ?? [:])
            }
            return apiResponse

        case .failure(_):
            throw VxHubError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }

    func signInRequest(provider: String, token: String, accountId: String, name: String?, email: String?, completion: @escaping @Sendable (_ response: DeviceRegisterResponse?, _ error: String?) -> Void) {
        Task {
            do {
                let response = try await signInRequest(provider: provider, token: token, accountId: accountId, name: name, email: email)
                await MainActor.run {
                    completion(response, nil)
                }
            } catch {
                VxLogger.shared.warning("Please check your network connection")
                await MainActor.run {
                    completion(nil, "VxLog: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Validate Promo Code (Async)

    func validatePromoCode(code: String) async throws -> VxPromoCode {
        let (data, response) = try await router.request(.usePromoCode(promoCode: code))

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VxHubError.unknown("Invalid response type")
        }

        VxLogger.shared.info("Promo code validation response: \(httpResponse.statusCode)")

        guard !data.isEmpty else {
            throw VxHubError.noData
        }

        let result = handleNetworkResponse(httpResponse)
        switch result {
        case .success:
            let successResponse = try JSONDecoder().decode(VxPromoCodeSuccessResponse.self, from: data)
            guard successResponse.success == true else {
                throw VxHubError.promoCodeInvalid(messages: ["Network Request is returned failed"])
            }

            let actionType: VxPromoCodeActionTypes = VxPromoCodeActionTypes(rawValue: successResponse.actionType ?? "premium") ?? .premium
            let actionMeta: VxPromoCodeActionMeta = VxPromoCodeActionMeta(data: successResponse.actionMeta,
                                                                          actionType: actionType)

            let promoData: VxPromoCodeData = VxPromoCodeData(actionType: actionType,
                                                             actionMeta: actionMeta,
                                                             extraData: successResponse.extraData)

            return VxPromoCode(data: promoData)

        case .failure(_):
            do {
                let errorResponse = try JSONDecoder().decode(VxPromoCodeErrorResponse.self, from: data)
                throw VxHubError.promoCodeInvalid(messages: errorResponse.message ?? ["Unknown error"])
            } catch let vxError as VxHubError {
                throw vxError
            } catch {
                throw VxHubError.promoCodeInvalid(messages: ["Decoding failed with error: \(error)"])
            }
        }
    }

    func validatePromoCode(code: String, completion: @escaping @Sendable (VxPromoCode) -> Void) {
        Task {
            do {
                let promoCode = try await validatePromoCode(code: code)
                await MainActor.run {
                    completion(promoCode)
                }
            } catch let error as VxHubError {
                await MainActor.run {
                    switch error {
                    case .promoCodeInvalid(let messages):
                        completion(VxPromoCode(error: VxPromoCodeErrorResponse(message: messages)))
                    default:
                        completion(VxPromoCode(error: VxPromoCodeErrorResponse(message: [error.localizedDescription])))
                    }
                }
            } catch {
                await MainActor.run {
                    completion(VxPromoCode(error: VxPromoCodeErrorResponse(message: [error.localizedDescription])))
                }
            }
        }
    }

    // MARK: - Get Products (Async)

    func getProducts() async throws -> [VxGetProductsResponse] {
        let (data, response) = try await router.request(.getProducts)
        let decoded = try decodeResponse([VxGetProductsResponse].self, data: data, response: response)
        return decoded
    }

    func getProducts(completion: @escaping @Sendable ([VxGetProductsResponse]?) -> Void) {
        Task {
            do {
                let products = try await getProducts()
                await MainActor.run {
                    completion(products)
                }
            } catch {
                VxLogger.shared.warning("Please check your network connection")
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }

    // MARK: - Get Tickets (Async)

    func getTickets() async throws -> [VxGetTicketsResponse] {
        let (data, response) = try await router.request(.getTickets)
        return try decodeResponse([VxGetTicketsResponse].self, data: data, response: response)
    }

    func getTickets(completion: @escaping @Sendable ([VxGetTicketsResponse]?) -> Void) {
        Task {
            do {
                let tickets = try await getTickets()
                await MainActor.run {
                    completion(tickets)
                }
            } catch {
                VxLogger.shared.warning("Please check your network connection")
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }

    // MARK: - Create New Ticket (Async)

    func createNewTicket(category: String, message: String) async throws -> VxCreateTicketSuccessResponse {
        let (data, response) = try await router.request(.createNewTicket(category: category, message: message))
        return try decodeResponse(VxCreateTicketSuccessResponse.self, data: data, response: response)
    }

    func createNewTicket(category: String, message: String, completion: @escaping @Sendable (VxCreateTicketSuccessResponse?) -> Void) {
        Task {
            do {
                let ticket = try await createNewTicket(category: category, message: message)
                await MainActor.run {
                    completion(ticket)
                }
            } catch {
                VxLogger.shared.warning("Please check your network connection")
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }

    // MARK: - Create New Message (Async)

    func createNewMessage(ticketId: String, message: String) async throws -> Message {
        let (data, response) = try await router.request(.createNewMessage(ticketId: ticketId, message: message))
        return try decodeResponse(Message.self, data: data, response: response)
    }

    func createNewMessage(ticketId: String, message: String, completion: @escaping @Sendable (Message?) -> Void) {
        Task {
            do {
                let message = try await createNewMessage(ticketId: ticketId, message: message)
                await MainActor.run {
                    completion(message)
                }
            } catch {
                VxLogger.shared.warning("Please check your network connection")
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }

    func sendConversationData(_ conversionInfo : [AnyHashable: Any]) {
        router.request(.sendConversationInfo(conversionInfo: conversionInfo)) { _, res, _ in }
    }

    // MARK: - Get Ticket Messages By Id (Async)

    func getTicketMessagesById(ticketId: String) async throws -> VxGetTicketMessagesResponse {
        let (data, response) = try await router.request(.getTicketMessages(ticketId: ticketId))
        return try decodeResponse(VxGetTicketMessagesResponse.self, data: data, response: response)
    }

    func getTicketMessagesById(ticketId: String, completion: @escaping @Sendable (VxGetTicketMessagesResponse?) -> Void) {
        Task {
            do {
                let messages = try await getTicketMessagesById(ticketId: ticketId)
                await MainActor.run {
                    completion(messages)
                }
            } catch {
                VxLogger.shared.warning("Please check your network connection")
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }

    // MARK: - Approve QR Code (Async)

    func approveQrCode(token: String) async throws -> Bool {
        let (data, response) = try await router.request(.approveQrLogin(token: token))

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VxHubError.unknown("Invalid response type")
        }

        VxLogger.shared.info("QR code approval response: \(httpResponse.statusCode)")
        let result = handleNetworkResponse(httpResponse)

        switch result {
        case .success:
            guard !data.isEmpty else {
                throw VxHubError.noData
            }
            let successResponse = try JSONDecoder().decode(VxApproveQrSuccessResponse.self, from: data)
            if successResponse.success == true {
                return true
            } else {
                throw VxHubError.unknown("QR approval failed")
            }

        case .failure(_):
            guard !data.isEmpty else {
                throw VxHubError.noData
            }
            do {
                let failResponse = try JSONDecoder().decode(VxApproveQrFailResponse.self, from: data)
                let errorMessage = failResponse.message ?? failResponse.error ?? "QR login failed with status: \(failResponse.statusCode ?? httpResponse.statusCode)"
                throw VxHubError.unknown(errorMessage)
            } catch let vxError as VxHubError {
                throw vxError
            } catch {
                throw VxHubError.decodingFailed(underlying: error)
            }
        }
    }

    func approveQrCode(token: String, completion: @escaping @Sendable (Bool, String?) -> Void) {
        Task {
            do {
                let success = try await approveQrCode(token: token)
                await MainActor.run {
                    completion(success, nil)
                }
            } catch {
                VxLogger.shared.warning("Please check your network connection")
                await MainActor.run {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Delete Account (Async)

    func deleteAccount() async throws -> Bool {
        let (data, response) = try await router.request(.deleteDevice)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VxHubError.unknown("Invalid response type")
        }

        VxLogger.shared.info("Delete account response: \(httpResponse.statusCode)")
        let result = handleNetworkResponse(httpResponse)

        switch result {
        case .success:
            guard !data.isEmpty else {
                throw VxHubError.noData
            }
            let successResponse = try JSONDecoder().decode(VxDeleteAccountResponse.self, from: data)
            if successResponse.success == true {
                return true
            } else {
                throw VxHubError.unknown("Delete account failed")
            }
        case .failure(_):
            throw VxHubError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }

    func deleteAccount(completion: @escaping @Sendable (Bool, String?) -> Void) {
        Task {
            do {
                let success = try await deleteAccount()
                await MainActor.run {
                    completion(success, nil)
                }
            } catch {
                VxLogger.shared.warning("Please check your network connection")
                await MainActor.run {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Get Tickets Unseen Status (Async)

    func getTicketsUnseenStatus() async throws -> Bool {
        let (data, response) = try await router.request(.getTicketsUnseenStatus)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VxHubError.unknown("Invalid response type")
        }

        VxLogger.shared.info("Unseen status response: \(httpResponse.statusCode)")
        let result = handleNetworkResponse(httpResponse)

        switch result {
        case .success:
            guard !data.isEmpty else {
                throw VxHubError.noData
            }
            let successResponse = try JSONDecoder().decode(VxGetTicketsUnseenStatusResponse.self, from: data)
            if let status = successResponse.status, status == "success", let unseenResponse = successResponse.unseenResponse {
                return unseenResponse
            } else {
                throw VxHubError.unknown("Unseen status failed")
            }

        case .failure(_):
            guard !data.isEmpty else {
                throw VxHubError.noData
            }
            do {
                let failResponse = try JSONDecoder().decode(VxGetTicketsUnseenStatusFailResponse.self, from: data)
                let errorMessage = failResponse.message ?? failResponse.error ?? "Unseen status failed with status: \(failResponse.statusCode ?? httpResponse.statusCode)"
                throw VxHubError.unknown(errorMessage)
            } catch let vxError as VxHubError {
                throw vxError
            } catch {
                throw VxHubError.decodingFailed(underlying: error)
            }
        }
    }

    func getTicketsUnseenStatus(completion: @escaping @Sendable (Bool, String?) -> Void) {
        Task {
            do {
                let status = try await getTicketsUnseenStatus()
                await MainActor.run {
                    completion(status, nil)
                }
            } catch {
                VxLogger.shared.warning("Please check your network connection")
                await MainActor.run {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Claim Retention Coin Gift (Async)

    func claimRetentionCoinGift() async throws -> VxClaimRetentionCoinGiftResponse {
        let (data, response) = try await router.request(.claimRetentionCoin)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VxHubError.unknown("Unknown error")
        }

        guard !data.isEmpty else {
            throw VxHubError.noData
        }

        let result = handleNetworkResponse(httpResponse)
        switch result {
        case .success:
            do {
                return try JSONDecoder().decode(VxClaimRetentionCoinGiftResponse.self, from: data)
            } catch {
                VxLogger.shared.error("Decoding failed with error: \(error)")
                throw VxHubError.decodingFailed(underlying: error)
            }
        case .failure(_):
            do {
                let failureResponse = try JSONDecoder().decode(VxClaimRetentionCoinGiftFailResponse.self, from: data)
                throw VxHubError.unknown(failureResponse.message ?? "Unknown failure")
            } catch let vxError as VxHubError {
                throw vxError
            } catch {
                throw VxHubError.unknown("Unknown failure")
            }
        }
    }

    func claimRetentionCoinGift(completion: @escaping @Sendable (Result<VxClaimRetentionCoinGiftResponse, VxClaimRetentionCoinGiftFailResponse>) -> Void) {
        Task {
            do {
                let response = try await claimRetentionCoinGift()
                await MainActor.run {
                    completion(.success(response))
                }
            } catch {
                await MainActor.run {
                    let errorResponse = VxClaimRetentionCoinGiftFailResponse(message: error.localizedDescription, error: nil, statusCode: nil)
                    completion(.failure(errorResponse))
                }
            }
        }
    }

    // MARK: - Get App Store Version (Async)

    func getAppStoreVersion() async throws -> String? {
        let (data, response) = try await router.request(.getAppStoreVersion)
        let decoded = try decodeResponse(AppStoreResponse.self, data: data, response: response)
        return decoded.results.first?.version
    }

    func getAppStoreVersion(completion: @escaping @Sendable (String?) -> Void) {
        Task {
            do {
                let version = try await getAppStoreVersion()
                await MainActor.run {
                    completion(version)
                }
            } catch {
                VxLogger.shared.warning("Please check your network connection")
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }

    // MARK: - Check Purchase Status (Async)

    func checkPurchaseStatus(transactionId: String, productId: String) async throws -> (success: Bool, premiumStatus: Bool?, balance: Int?) {
        let (data, response) = try await router.request(.afterPurchaseCheck(transactionId: transactionId, productId: productId))

        guard let httpResponse = response as? HTTPURLResponse else {
            return (false, nil, nil)
        }

        guard !data.isEmpty else {
            return (false, nil, nil)
        }

        let result = handleNetworkResponse(httpResponse)
        switch result {
        case .success:
            do {
                let json = try JSONDecoder().decode(SuccessResponse.self, from: data)
                return (true, json.device.premium_status, json.device.balance)
            } catch {
                debugPrint("JSON decoding error: \(error)")
                return (false, nil, nil)
            }
        case .failure(let statusCode):
            debugPrint("Failed with status code: \(statusCode)")
            if let dataString = String(data: data, encoding: .utf8) {
                debugPrint("Error response: \(dataString)")
            }
            return (false, nil, nil)
        }
    }

    func checkPurchaseStatus(transactionId: String, productId: String, completion: @escaping @Sendable (Bool, Bool?, Int?) -> Void) {
        Task {
            let result = try? await checkPurchaseStatus(transactionId: transactionId, productId: productId)
            await MainActor.run {
                completion(result?.success ?? false, result?.premiumStatus, result?.balance)
            }
        }
    }

    // Define response structures
    struct SuccessResponse: Codable {
        let status: String
        let vid: String
        let device: Device
    }

    struct Device: Codable {
        let premium_status: Bool
        let balance: Int
    }

    struct ErrorResponse: Codable {
        let message: String
        let error: String
        let statusCode: Int
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
