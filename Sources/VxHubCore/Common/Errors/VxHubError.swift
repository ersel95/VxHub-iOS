//
//  VxHubError.swift
//  VxHub
//
//  Created on 07.02.2026.
//

import Foundation

public enum VxHubError: Error, Sendable, LocalizedError {
    case networkUnavailable
    case requestFailed(statusCode: Int)
    case noData
    case decodingFailed(underlying: Error)
    case invalidURL(String)
    case purchaseFailed(reason: String?)
    case signInFailed(provider: String, reason: String)
    case promoCodeInvalid(messages: [String])

    // MARK: - Account authentication
    /// No signed-in account; the call needed one.
    case notSignedIn
    /// The refresh token is spent, revoked or expired — sign in again.
    case sessionExpired
    /// Nothing decoded from an otherwise successful response.
    case decodingError
    /**
     The API refused the request with a machine-readable code such as
     `INVALID_CREDENTIALS`, `EMAIL_ALREADY_REGISTERED`, `PASSWORD_TOO_SHORT:10`,
     `INVALID_CODE`, `EMAIL_NOT_VERIFIED` or a rate-limit code. Branch on `code`
     rather than on the message.
     */
    case authFailed(code: String, statusCode: Int)

    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network is unavailable. Please check your connection."
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        case .noData:
            return "Response returned with no data."
        case .decodingFailed(let underlying):
            return "Failed to decode response: \(underlying.localizedDescription)"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .purchaseFailed(let reason):
            return "Purchase failed: \(reason ?? "Unknown reason")"
        case .signInFailed(let provider, let reason):
            return "Sign in with \(provider) failed: \(reason)"
        case .promoCodeInvalid(let messages):
            return "Promo code invalid: \(messages.joined(separator: ", "))"
        case .notSignedIn:
            return "No account is signed in."
        case .sessionExpired:
            return "The session has expired. Please sign in again."
        case .decodingError:
            return "Failed to decode the response."
        case .authFailed(let code, let statusCode):
            return "Authentication failed (\(statusCode)): \(code)"
        case .unknown(let message):
            return message
        }
    }
}
