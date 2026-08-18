//
//  VxUserSession.swift
//  VxHub
//

import Foundation

/// Tokens for a signed-in account, kept in the Keychain between launches.
public struct VxUserSession: Codable, Sendable {
    /// Short-lived; sent as the bearer token on every authenticated call.
    public let accessToken: String
    /// Long-lived and rotated on every use — the SDK never sends it twice.
    public let refreshToken: String
    /// When `accessToken` stops being accepted.
    public let expiresAt: Date

    public init(accessToken: String, refreshToken: String, expiresAt: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }

    public init(accessToken: String, refreshToken: String, expiresIn: Int) {
        self.init(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: Date().addingTimeInterval(TimeInterval(expiresIn)),
        )
    }

    /// Refreshed a little early, so a call does not fail on a token that
    /// expires while it is in flight.
    var needsRefresh: Bool {
        expiresAt.timeIntervalSinceNow < 30
    }
}

/// The signed-in person, as the app sees them.
public struct VxUser: Codable, Sendable {
    public let id: String
    public let email: String?
    public let emailVerified: Bool
    public let name: String?
    public let profilePicture: String?
    /// Which methods this account can sign in with: password, google, apple.
    public let providers: [String]
    public let premiumStatus: Bool
    public let premiumEndDate: String?
    public let balance: Int?
    /// True after an admin issued a temporary password.
    public let mustChangePassword: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case emailVerified = "email_verified"
        case name
        case profilePicture = "profile_picture"
        case providers
        case premiumStatus = "premium_status"
        case premiumEndDate = "premium_end_date"
        case balance
        case mustChangePassword = "must_change_password"
    }
}

/// Which sign-in methods the panel has switched on for this app.
public struct VxAuthConfig: Codable, Sendable {
    public let authEnabled: Bool
    public let passwordEnabled: Bool
    public let googleEnabled: Bool
    public let appleEnabled: Bool
    public let requireEmailVerification: Bool
    public let minPasswordLength: Int
    public let requirePasswordComplexity: Bool
    public let googleClientId: String?

    enum CodingKeys: String, CodingKey {
        case authEnabled = "auth_enabled"
        case passwordEnabled = "password_enabled"
        case googleEnabled = "google_enabled"
        case appleEnabled = "apple_enabled"
        case requireEmailVerification = "require_email_verification"
        case minPasswordLength = "min_password_length"
        case requirePasswordComplexity = "require_password_complexity"
        case googleClientId = "google_client_id"
    }
}

/// What the auth endpoints answer with.
internal struct VxAuthResponse: Codable, Sendable {
    let status: String?
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let user: VxUser
    let vid: String?

    enum CodingKeys: String, CodingKey {
        case status
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case user
        case vid
    }
}

internal struct VxSuccessResponse: Codable, Sendable {
    let success: Bool?
    let emailVerified: Bool?

    enum CodingKeys: String, CodingKey {
        case success
        case emailVerified = "email_verified"
    }
}

internal struct VxUserResponse: Codable, Sendable {
    let user: VxUser
}
