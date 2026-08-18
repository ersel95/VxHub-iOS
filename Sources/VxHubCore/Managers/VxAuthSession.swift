//
//  VxAuthSession.swift
//  VxHub
//

import Foundation

/**
 Holds the signed-in session and keeps its access token usable.

 An actor because refreshing must happen once: several screens can hit a 401 at
 the same moment, and without serialization each would spend the refresh token
 separately. Since rotation invalidates the previous token, the second call
 would look like a stolen token to the server and end every session — the exact
 opposite of what a routine refresh should do.
 */
internal actor VxAuthSession {
    static let shared = VxAuthSession()

    private var session: VxUserSession?
    private var user: VxUser?
    private var refreshTask: Task<Bool, Never>?

    private let keychain = VxKeychainManager()

    private init() {
        session = keychain.getUserSession()
    }

    // MARK: - State

    var currentSession: VxUserSession? { session }
    var currentUser: VxUser? { user }
    var isSignedIn: Bool { session != nil }

    func store(session: VxUserSession, user: VxUser?) {
        self.session = session
        if let user { self.user = user }
        keychain.saveUserSession(session)
    }

    func updateUser(_ user: VxUser) {
        self.user = user
    }

    func clear() {
        session = nil
        user = nil
        refreshTask?.cancel()
        refreshTask = nil
        keychain.clearUserSession()
    }

    // MARK: - Refresh

    /// Refreshes ahead of expiry so a call is not sent with a token that dies in flight.
    func ensureFreshToken() async throws {
        guard let session else { throw VxHubError.notSignedIn }
        guard session.needsRefresh else { return }
        guard await refreshNow() else { throw VxHubError.sessionExpired }
    }

    /// Refreshes once even when called concurrently; every caller awaits the same attempt.
    func refreshNow() async -> Bool {
        if let existing = refreshTask {
            return await existing.value
        }
        guard let refreshToken = session?.refreshToken else { return false }

        let task = Task<Bool, Never> { [weak self] in
            guard let self else { return false }
            do {
                let response = try await VxAuthNetworkManager().refresh(refreshToken: refreshToken)
                await self.store(
                    session: VxUserSession(
                        accessToken: response.accessToken,
                        refreshToken: response.refreshToken,
                        expiresIn: response.expiresIn,
                    ),
                    user: response.user,
                )
                return true
            } catch {
                // The refresh token is spent or revoked: the session is over, and
                // holding on to it would only produce more failures.
                VxLogger.shared.warning("Session refresh failed, signing out: \(error)")
                await self.clear()
                await MainActor.run {
                    VxHub.shared.delegate?.vxHubUserSessionExpired()
                }
                return false
            }
        }

        refreshTask = task
        let result = await task.value
        refreshTask = nil
        return result
    }
}
