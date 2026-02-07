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
        case .unknown(let message):
            return message
        }
    }
}
