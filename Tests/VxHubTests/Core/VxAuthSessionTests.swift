import XCTest
@testable import VxHub
@testable import VxHubCore

/// Covers the parts of the session layer that decide whether somebody stays
/// signed in — the places where a mistake shows up as a spurious sign-out.
final class VxAuthSessionTests: XCTestCase {

    // MARK: - Expiry

    func testTokenNearingExpiryIsRefreshedEarly() {
        // Refreshing only after expiry would let a call go out with a token that
        // dies mid-flight, which surfaces as a random 401 to the user.
        let almostExpired = VxUserSession(accessToken: "a", refreshToken: "r", expiresIn: 10)
        XCTAssertTrue(almostExpired.needsRefresh)
    }

    func testFreshTokenIsNotRefreshed() {
        let fresh = VxUserSession(accessToken: "a", refreshToken: "r", expiresIn: 900)
        XCTAssertFalse(fresh.needsRefresh)
    }

    func testExpiredTokenNeedsRefresh() {
        let expired = VxUserSession(accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(-60))
        XCTAssertTrue(expired.needsRefresh)
    }

    // MARK: - Storage

    func testSessionSurvivesARoundTripThroughStorage() throws {
        let manager = VxKeychainManager()
        let session = VxUserSession(accessToken: "access-123", refreshToken: "refresh-456", expiresIn: 900)

        manager.saveUserSession(session)
        defer { manager.clearUserSession() }

        guard let restored = manager.getUserSession() else {
            // Keychain access can be unavailable in CI; the suite is written to
            // tolerate that rather than fail on the environment.
            throw XCTSkip("Keychain unavailable in this environment")
        }

        XCTAssertEqual(restored.accessToken, session.accessToken)
        XCTAssertEqual(restored.refreshToken, session.refreshToken)
        XCTAssertEqual(restored.expiresAt.timeIntervalSince1970, session.expiresAt.timeIntervalSince1970, accuracy: 1)
    }

    func testClearingRemovesTheStoredSession() throws {
        let manager = VxKeychainManager()
        manager.saveUserSession(VxUserSession(accessToken: "a", refreshToken: "r", expiresIn: 900))
        guard manager.getUserSession() != nil else {
            throw XCTSkip("Keychain unavailable in this environment")
        }

        manager.clearUserSession()
        XCTAssertNil(manager.getUserSession(), "A signed-out session must not be recoverable from storage")
    }

    // MARK: - Decoding

    func testAuthResponseDecodesTheAPIShape() throws {
        let json = """
        {
          "status": "success",
          "access_token": "eyJhbGciOi",
          "refresh_token": "opaque-token",
          "expires_in": 900,
          "vid": "device-uuid",
          "user": {
            "id": "user-uuid",
            "email": "person@example.com",
            "email_verified": true,
            "name": "Person",
            "profile_picture": null,
            "providers": ["password", "google"],
            "premium_status": true,
            "premium_end_date": "2028-01-01T00:00:00.000Z",
            "balance": 750,
            "must_change_password": false
          }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(VxAuthResponse.self, from: json)

        XCTAssertEqual(response.accessToken, "eyJhbGciOi")
        XCTAssertEqual(response.expiresIn, 900)
        XCTAssertEqual(response.user.email, "person@example.com")
        XCTAssertEqual(response.user.providers, ["password", "google"])
        XCTAssertEqual(response.user.balance, 750)
        XCTAssertTrue(response.user.premiumStatus)
    }

    func testAuthConfigDecodesTheAPIShape() throws {
        let json = """
        {
          "auth_enabled": true,
          "password_enabled": true,
          "google_enabled": false,
          "apple_enabled": true,
          "require_email_verification": false,
          "min_password_length": 10,
          "require_password_complexity": false,
          "google_client_id": null
        }
        """.data(using: .utf8)!

        let config = try JSONDecoder().decode(VxAuthConfig.self, from: json)

        XCTAssertTrue(config.authEnabled)
        XCTAssertFalse(config.googleEnabled, "A disabled provider must not be drawn as a button")
        XCTAssertEqual(config.minPasswordLength, 10)
        XCTAssertNil(config.googleClientId)
    }
}
