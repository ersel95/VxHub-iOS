//
//  VxAuthNetworkManager.swift
//  VxHub
//

import Foundation

/**
 Network calls for account authentication.

 Separate from `VxNetworkManager`, whose calls identify a device. These identify
 a person, and they are the only ones that carry a bearer token — which is also
 why the refresh handling lives here rather than in the shared router.
 */
internal final class VxAuthNetworkManager: @unchecked Sendable {
    private let router = Router<VxHubApi>()

    init() {}

    // MARK: - Calls

    func config() async throws -> VxAuthConfig {
        try await send(.authConfig, as: VxAuthConfig.self, authenticated: false)
    }

    func register(email: String, password: String, name: String?) async throws -> VxAuthResponse {
        try await send(.authRegister(email: email, password: password, name: name), as: VxAuthResponse.self, authenticated: false)
    }

    func login(email: String, password: String) async throws -> VxAuthResponse {
        try await send(.authLogin(email: email, password: password), as: VxAuthResponse.self, authenticated: false)
    }

    func socialLogin(provider: String, token: String, accountId: String?, name: String?, email: String?) async throws -> VxAuthResponse {
        try await send(
            .authSocialLogin(provider: provider, token: token, accountId: accountId, name: name, email: email),
            as: VxAuthResponse.self,
            authenticated: false,
        )
    }

    func refresh(refreshToken: String) async throws -> VxAuthResponse {
        try await send(.authRefresh(refreshToken: refreshToken), as: VxAuthResponse.self, authenticated: false)
    }

    func logout(refreshToken: String?) async throws {
        _ = try await send(.authLogout(refreshToken: refreshToken), as: VxSuccessResponse.self, authenticated: false)
    }

    func forgotPassword(email: String) async throws {
        _ = try await send(.authForgotPassword(email: email), as: VxSuccessResponse.self, authenticated: false)
    }

    func resetPassword(email: String, code: String, newPassword: String) async throws {
        _ = try await send(
            .authResetPassword(email: email, code: code, newPassword: newPassword),
            as: VxSuccessResponse.self,
            authenticated: false,
        )
    }

    func verifyEmail(code: String) async throws {
        _ = try await send(.authVerifyEmail(code: code), as: VxSuccessResponse.self, authenticated: true)
    }

    func resendVerification() async throws {
        _ = try await send(.authResendVerification, as: VxSuccessResponse.self, authenticated: true)
    }

    func changePassword(current: String, new: String) async throws {
        _ = try await send(.authChangePassword(current: current, new: new), as: VxSuccessResponse.self, authenticated: true)
    }

    func me() async throws -> VxUser {
        try await send(.authMe, as: VxUserResponse.self, authenticated: true).user
    }

    func updateProfile(name: String?, profilePicture: String?) async throws -> VxUser {
        try await send(.authUpdateProfile(name: name, profilePicture: profilePicture), as: VxUserResponse.self, authenticated: true).user
    }

    func deleteAccount() async throws {
        _ = try await send(.authDeleteAccount, as: VxSuccessResponse.self, authenticated: true)
    }

    // MARK: - Transport

    /**
     Sends a request and decodes it, refreshing the access token once if the
     server rejects it.

     A 401 on an authenticated call is the normal way an expired token shows up.
     Refreshing and retrying once keeps that invisible to the person using the
     app; a second failure means the session is genuinely over, and the caller
     gets `sessionExpired` rather than a silent no-op.
     */
    private func send<T: Decodable>(_ route: VxHubApi, as type: T.Type, authenticated: Bool) async throws -> T {
        if authenticated {
            try await VxAuthSession.shared.ensureFreshToken()
        }

        do {
            return try await perform(route, as: type)
        } catch let error as VxHubError {
            guard authenticated, case .requestFailed(let status) = error, status == 401 else { throw error }

            // The token was rejected despite looking fresh — refresh once, then retry.
            let refreshed = await VxAuthSession.shared.refreshNow()
            guard refreshed else { throw VxHubError.sessionExpired }
            return try await perform(route, as: type)
        }
    }

    private func perform<T: Decodable>(_ route: VxHubApi, as type: T.Type) async throws -> T {
        let (data, response) = try await router.request(route)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VxHubError.unknown("Invalid response type")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // The API answers with a machine-readable code; surfacing it lets the
            // caller branch on the reason instead of parsing prose.
            let message = Self.errorMessage(from: data)
            if httpResponse.statusCode == 401 {
                throw VxHubError.requestFailed(statusCode: 401)
            }
            throw VxHubError.authFailed(code: message ?? "REQUEST_FAILED", statusCode: httpResponse.statusCode)
        }

        guard !data.isEmpty else { throw VxHubError.noData }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            VxLogger.shared.error("Could not decode \(T.self): \(error)")
            throw VxHubError.decodingError
        }
    }

    /// Pulls the API's error code out of the body, whether it came as a string
    /// or as validation's array of messages.
    private static func errorMessage(from data: Data) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        if let message = object["message"] as? String { return message }
        if let messages = object["message"] as? [String] { return messages.first }
        return object["error"] as? String
    }
}
