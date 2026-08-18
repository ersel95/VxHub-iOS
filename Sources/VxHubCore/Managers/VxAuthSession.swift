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
    private var refreshGeneration: UInt64 = 0

    private let keychain = VxKeychainManager()

    /// Marks that this install has run before. Keychain items outlive the app,
    /// UserDefaults do not — the pair is what tells a reinstall apart.
    private static let installMarkerKey = "com.vxhub.auth.installMarker"

    private init() {
        // Deleting an app does not clear its keychain, so a reinstall would
        // otherwise start signed in as whoever used the device last — including
        // on a resold or handed-down phone. Drop the leftover session instead.
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Self.installMarkerKey) == nil {
            keychain.clearUserSession()
            defaults.set(true, forKey: Self.installMarkerKey)
            session = nil
        } else {
            session = keychain.getUserSession()
        }
        VxAuthStateStore.shared.session = session
    }

    // MARK: - State

    var currentSession: VxUserSession? { session }
    var currentUser: VxUser? { user }
    var isSignedIn: Bool { session != nil }

    /**
     Records a session everywhere it is read from.

     The mirror matters as much as the actor: request headers read the token
     from `VxAuthStateStore`, so a refresh that updated only the actor would keep
     sending the old token, get another 401, and spend the refresh token again —
     which the server reads as a stolen token and answers by ending every
     session. Both must move together.
     */
    func store(session: VxUserSession, user: VxUser?) {
        self.session = session
        if let user { self.user = user }
        keychain.saveUserSession(session)

        VxAuthStateStore.shared.session = session
        if let user { VxAuthStateStore.shared.user = user }
    }

    func updateUser(_ user: VxUser) {
        self.user = user
        VxAuthStateStore.shared.user = user
    }

    func clear() {
        session = nil
        user = nil
        refreshTask?.cancel()
        refreshTask = nil
        keychain.clearUserSession()

        // Without this `isAuthenticated` stays true after the session ended, and
        // the app keeps showing a signed-in state whose every call fails.
        VxAuthStateStore.shared.session = nil
        VxAuthStateStore.shared.user = nil
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

        // `Task` is a value type, so identity has to be tracked separately to
        // tell our own attempt apart from a later one.
        refreshGeneration &+= 1
        let generation = refreshGeneration

        let task = Task<Bool, Never> { [weak self] in
            guard let self else { return false }
            do {
                let response = try await VxAuthNetworkManager().refresh(refreshToken: refreshToken)
                await self.store(
                    session: VxUserSession(
                        accessToken: response.accessToken,
                        refreshToken: response.refreshToken,
                        expiresIn: response.expiresIn
                    ),
                    user: response.user
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
        // Only clear our own attempt: `clear()` may have reset it and another
        // caller may already have started a new one. Blindly nilling it would
        // let a second refresh run with the same token — the very thing this
        // serialization exists to prevent.
        if refreshGeneration == generation { refreshTask = nil }
        return result
    }
}
