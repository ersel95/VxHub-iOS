//
//  VxHub+Auth.swift
//  VxHub
//

import Foundation

/**
 Account authentication.

 Sign-up, sign-in, password reset and email verification for the app's own
 users, on top of the device identity the SDK already maintains. Which methods
 are available is decided in the VxHub panel and delivered in `authConfig`, so
 turning Google off for an app needs no release.

 A signed-in session survives relaunches: tokens live in the Keychain, the
 access token is refreshed silently, and `vxHubUserSessionExpired()` fires only
 when the session genuinely cannot continue.
 */
public extension VxHub {

    // MARK: - State

    /// The signed-in account, or nil when nobody is signed in.
    var currentUser: VxUser? {
        VxAuthStateStore.shared.user
    }

    var isAuthenticated: Bool {
        VxAuthStateStore.shared.session != nil
    }

    /// Which sign-in methods the panel enabled, fetched during initialization.
    var authConfig: VxAuthConfig? {
        VxAuthStateStore.shared.config
    }

    /// Bearer token for the current request, if any. Used when building headers.
    internal var currentAccessToken: String? {
        VxAuthStateStore.shared.session?.accessToken
    }

    // MARK: - Lifecycle

    /**
     Restores a stored session and fetches the panel's auth configuration.

     Called during `initialize`. A stored session is trusted until the API says
     otherwise, so the app can render its signed-in state immediately instead of
     waiting on a network round trip; the profile is then refreshed in the
     background and a rejected token signs the person out.
     */
    internal func restoreAuthState() {
        Task {
            let stored = VxKeychainManager().getUserSession()
            if let stored {
                await VxAuthSession.shared.store(session: stored, user: nil)
                VxAuthStateStore.shared.session = stored
            }

            if let config = try? await VxAuthNetworkManager().config() {
                VxAuthStateStore.shared.config = config
            }

            guard stored != nil else { return }
            do {
                let user = try await VxAuthNetworkManager().me()
                await VxAuthSession.shared.updateUser(user)
                VxAuthStateStore.shared.user = user
            } catch {
                VxLogger.shared.warning("Stored session could not be restored: \(error)")
            }
        }
    }

    // MARK: - Email and password

    func signUp(email: String, password: String, name: String? = nil) async throws -> VxUser {
        let response = try await VxAuthNetworkManager().register(email: email, password: password, name: name)
        return await adopt(response)
    }

    func signIn(email: String, password: String) async throws -> VxUser {
        let response = try await VxAuthNetworkManager().login(email: email, password: password)
        return await adopt(response)
    }

    /**
     Asks for a reset code.

     Always succeeds, whether or not the address has an account — the API will
     not confirm which, and the app should say "check your inbox" either way.
     */
    func forgotPassword(email: String) async throws {
        try await VxAuthNetworkManager().forgotPassword(email: email)
    }

    func resetPassword(email: String, code: String, newPassword: String) async throws {
        try await VxAuthNetworkManager().resetPassword(email: email, code: code, newPassword: newPassword)
    }

    func verifyEmail(code: String) async throws {
        try await VxAuthNetworkManager().verifyEmail(code: code)
        try? await refreshCurrentUser()
    }

    func resendVerificationCode() async throws {
        try await VxAuthNetworkManager().resendVerification()
    }

    func changePassword(current: String, new: String) async throws {
        try await VxAuthNetworkManager().changePassword(current: current, new: new)
        try? await refreshCurrentUser()
    }

    // MARK: - Profile

    @discardableResult
    func updateProfile(name: String? = nil, profilePicture: String? = nil) async throws -> VxUser {
        let user = try await VxAuthNetworkManager().updateProfile(name: name, profilePicture: profilePicture)
        await VxAuthSession.shared.updateUser(user)
        VxAuthStateStore.shared.user = user
        return user
    }

    @discardableResult
    func refreshCurrentUser() async throws -> VxUser {
        let user = try await VxAuthNetworkManager().me()
        await VxAuthSession.shared.updateUser(user)
        VxAuthStateStore.shared.user = user
        return user
    }

    // MARK: - Signing out

    /**
     Signs out.

     The local session is cleared whatever the server says: a network failure
     must not leave someone stuck signed in on a device they are trying to leave.
     */
    func signOut(allDevices: Bool = false) async {
        let session = await VxAuthSession.shared.currentSession
        do {
            if allDevices {
                _ = try? await VxAuthNetworkManager().logout(refreshToken: nil)
            } else {
                try await VxAuthNetworkManager().logout(refreshToken: session?.refreshToken)
            }
        } catch {
            VxLogger.shared.warning("Sign-out call failed, clearing locally anyway: \(error)")
        }
        await VxAuthSession.shared.clear()
        VxAuthStateStore.shared.session = nil
        VxAuthStateStore.shared.user = nil
        // The device keeps its own identity, so purchases and support carry on.
        // Explicit completion picks the callback overload over the async one.
        handleLogout(completion: nil)
    }

    /// Deletes the account. The device stays, unattached.
    func deleteAuthenticatedAccount() async throws {
        try await VxAuthNetworkManager().deleteAccount()
        await VxAuthSession.shared.clear()
        VxAuthStateStore.shared.session = nil
        VxAuthStateStore.shared.user = nil
    }

    // MARK: - Social sign-in

    /**
     Routes a verified provider token to whichever backend flow applies.

     When the panel has account auth on for this provider, the token goes to the
     account endpoint and comes back as a signed-in session. When it does not,
     the call falls through to the device endpoint exactly as before — which is
     what keeps apps whose projects have not enabled accounts working unchanged.

     Returns true when an account session was established.
     */
    internal func completeSocialSignIn(
        provider: String,
        token: String,
        accountId: String?,
        name: String?,
        email: String?,
    ) async -> Bool {
        let config = VxAuthStateStore.shared.config
        let enabledForProvider = provider == "google" ? config?.googleEnabled : config?.appleEnabled
        guard config?.authEnabled == true, enabledForProvider == true else { return false }

        do {
            let response = try await VxAuthNetworkManager().socialLogin(
                provider: provider,
                token: token,
                accountId: accountId,
                name: name,
                email: email,
            )
            _ = await adopt(response)
            return true
        } catch {
            // An account-layer problem must not break a sign-in that worked
            // before accounts existed; the device flow still runs.
            VxLogger.shared.warning("Account social sign-in failed, falling back to the device flow: \(error)")
            return false
        }
    }

    // MARK: - Internals

    /// Stores what an auth response returned and publishes it to observers.
    internal func adopt(_ response: VxAuthResponse) async -> VxUser {
        let session = VxUserSession(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresIn: response.expiresIn,
        )
        await VxAuthSession.shared.store(session: session, user: response.user)
        VxAuthStateStore.shared.session = session
        VxAuthStateStore.shared.user = response.user
        return response.user
    }
}

// MARK: - Callback API

public extension VxHub {
    func signUp(email: String, password: String, name: String? = nil, completion: @escaping @Sendable (Result<VxUser, VxHubError>) -> Void) {
        Task { await Self.deliver(completion) { try await self.signUp(email: email, password: password, name: name) } }
    }

    func signIn(email: String, password: String, completion: @escaping @Sendable (Result<VxUser, VxHubError>) -> Void) {
        Task { await Self.deliver(completion) { try await self.signIn(email: email, password: password) } }
    }

    func forgotPassword(email: String, completion: @escaping @Sendable (Result<Void, VxHubError>) -> Void) {
        Task { await Self.deliver(completion) { try await self.forgotPassword(email: email) } }
    }

    func resetPassword(email: String, code: String, newPassword: String, completion: @escaping @Sendable (Result<Void, VxHubError>) -> Void) {
        Task { await Self.deliver(completion) { try await self.resetPassword(email: email, code: code, newPassword: newPassword) } }
    }

    func verifyEmail(code: String, completion: @escaping @Sendable (Result<Void, VxHubError>) -> Void) {
        Task { await Self.deliver(completion) { try await self.verifyEmail(code: code) } }
    }

    func resendVerificationCode(completion: @escaping @Sendable (Result<Void, VxHubError>) -> Void) {
        Task { await Self.deliver(completion) { try await self.resendVerificationCode() } }
    }

    func changePassword(current: String, new: String, completion: @escaping @Sendable (Result<Void, VxHubError>) -> Void) {
        Task { await Self.deliver(completion) { try await self.changePassword(current: current, new: new) } }
    }

    func updateProfile(name: String? = nil, profilePicture: String? = nil, completion: @escaping @Sendable (Result<VxUser, VxHubError>) -> Void) {
        Task { await Self.deliver(completion) { try await self.updateProfile(name: name, profilePicture: profilePicture) } }
    }

    func signOut(allDevices: Bool = false, completion: @escaping @Sendable () -> Void) {
        Task {
            await signOut(allDevices: allDevices)
            await MainActor.run { completion() }
        }
    }

    /// Completion handlers always land on the main thread, as everywhere else in the SDK.
    private static func deliver<T>(
        _ completion: @escaping @Sendable (Result<T, VxHubError>) -> Void,
        _ work: @escaping () async throws -> T,
    ) async {
        do {
            let value = try await work()
            await MainActor.run { completion(.success(value)) }
        } catch let error as VxHubError {
            await MainActor.run { completion(.failure(error)) }
        } catch {
            await MainActor.run { completion(.failure(.unknown(error.localizedDescription))) }
        }
    }
}
