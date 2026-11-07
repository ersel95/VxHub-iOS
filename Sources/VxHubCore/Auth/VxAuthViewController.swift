#if canImport(UIKit)
//
//  VxAuthViewController.swift
//  VxHub
//

import UIKit
import AuthenticationServices

/**
 The ready-made sign-in flow.

 One controller drives every step — sign in, sign up, forgot password, code
 entry, new password — because they share a single form and differ mostly in
 which fields and copy are showing. Moving between them is a state change rather
 than a push, which keeps the keyboard up and avoids a stack of half-filled
 screens behind the user.

 Which providers appear comes from `VxHub.shared.authConfig`, so an app does not
 decide, and does not need a release when the panel changes.
 */
public final class VxAuthViewController: VxNiblessViewController {

    // MARK: - Dependencies

    private let configuration: VxAuthConfiguration
    private var onFinish: ((VxAuthResult) -> Void)?

    private var step: VxAuthStep {
        didSet {
            guard oldValue != step else { return }
            rootView.clearError()
            rootView.clearCode()
            applyStep(animated: true)
        }
    }

    /// Guards against a second result — a slow request finishing after the
    /// person already closed the screen would otherwise call back twice and
    /// dismiss whatever the app presented in the meantime.
    private var hasFinished = false

    /// Held between steps: the address a code was sent to, and the code itself.
    private var pendingEmail: String = ""
    private var pendingCode: String = ""
    /**
     The password someone signed in with, kept only while they are being asked
     to replace it.

     An operator-issued temporary password arrives by email in clear text and
     has been seen by whoever issued it, so the account is not really theirs
     until it is changed. Changing it needs the current one, and asking them to
     type it a second time on the very next screen is the kind of friction that
     ends with the temporary password being kept forever.
     */
    private var passwordAwaitingChange: String?

    private var authConfig: VxAuthConfig? { VxHub.shared.authConfig }

    /// Watches for the panel configuration arriving after the screen is up.
    /// nonisolated(unsafe) because deinit runs outside the main actor and Swift 6
    /// will not let it read actor state; the token is written once, in viewDidLoad.
    private nonisolated(unsafe) var configObserver: NSObjectProtocol?

    // MARK: - Views

    private lazy var rootView = VxAuthRootView(configuration: configuration)

    // MARK: - Init

    public init(
        configuration: VxAuthConfiguration = VxAuthConfiguration(),
        startingAt step: VxAuthStep = .signIn,
        onFinish: ((VxAuthResult) -> Void)? = nil
    ) {
        self.configuration = configuration
        self.step = step
        self.onFinish = onFinish
        super.init()
    }

    // MARK: - Lifecycle

    public override func loadView() {
        view = rootView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = configuration.backgroundColor
        wireActions()
        observeConfig()
        applyStep(animated: false)
    }

    deinit {
        if let configObserver {
            NotificationCenter.default.removeObserver(configObserver)
        }
    }

    /**
     Redraws when the auth configuration lands.

     The configuration is fetched during initialization, so a screen presented
     early — a sign-in wall on first launch, typically — renders before it
     arrives. Without this the Google and Apple buttons would simply never
     appear, since the view draws only the providers it knows are enabled.
     */
    private func observeConfig() {
        configObserver = NotificationCenter.default.addObserver(
            forName: .vxHubAuthStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.applyStep(animated: true)
        }
    }

    // MARK: - Wiring

    private func wireActions() {
        rootView.onPrimaryTapped = { [weak self] in self?.submit() }
        rootView.onSecondaryTapped = { [weak self] in self?.handleSecondaryAction() }
        rootView.onForgotTapped = { [weak self] in self?.step = .forgotPassword }
        rootView.onCloseTapped = { [weak self] in self?.finish(.cancelled) }
        rootView.onGuestTapped = { [weak self] in self?.finish(.continuedAsGuest) }
        rootView.onGoogleTapped = { [weak self] in self?.signInWithGoogle() }
        rootView.onAppleTapped = { [weak self] in self?.signInWithApple() }
        rootView.onResendTapped = { [weak self] in self?.resendCode() }
    }

    private func applyStep(animated: Bool) {
        rootView.render(
            step: step,
            authConfig: authConfig,
            email: pendingEmail,
            animated: animated
        )
    }

    /// The secondary link means different things per step; on the code steps it
    /// is the only way to correct a mistyped address without abandoning the flow.
    private func handleSecondaryAction() {
        switch step {
        case .signIn: step = .signUp
        case .signUp, .forgotPassword: step = .signIn
        case .enterCode: step = .forgotPassword
        case .newPassword:
            // With a temporary password there is nowhere back to: the account
            // is not usable until this is done.
            step = passwordAwaitingChange == nil ? .enterCode : .signIn
        case .verifyEmail: step = .signIn
        }
    }

    // MARK: - Submitting

    private func submit() {
        rootView.clearError()
        switch step {
        case .signIn: performSignIn()
        case .signUp: performSignUp()
        case .forgotPassword: requestResetCode()
        case .enterCode: acceptCode()
        case .newPassword: saveNewPassword()
        case .verifyEmail: verifyEmailCode()
        }
    }

    private func performSignIn() {
        let email = rootView.emailText
        let password = rootView.passwordText
        guard validate(email: email, password: password) else { return }

        rootView.isBusy = true
        passwordAwaitingChange = password
        VxHub.shared.signIn(email: email, password: password) { [weak self] result in
            self?.handle(result)
        }
    }

    private func performSignUp() {
        let email = rootView.emailText
        let password = rootView.passwordText
        guard validate(email: email, password: password) else { return }

        rootView.isBusy = true
        VxHub.shared.signUp(email: email, password: password, name: rootView.nameText) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let user):
                self.rootView.isBusy = false
                // Signing up already returns a session; the address is confirmed
                // afterwards, and only blocks anything when the project requires it.
                if self.authConfig?.requireEmailVerification == true, !user.emailVerified {
                    self.pendingEmail = user.email ?? email
                    self.step = .verifyEmail
                } else {
                    self.finish(.signedIn(user))
                }
            case .failure(let error):
                self.show(error)
            }
        }
    }

    private func requestResetCode() {
        let email = rootView.emailText
        guard isValidEmail(email) else {
            rootView.showError(VxLocalizables.Auth.errorGeneric)
            return
        }

        rootView.isBusy = true
        VxHub.shared.forgotPassword(email: email) { [weak self] result in
            guard let self else { return }
            self.rootView.isBusy = false
            switch result {
            case .success:
                // The API will not say whether the address exists, so neither
                // does this screen — it moves on either way.
                self.pendingEmail = email
                self.step = .enterCode
                // After the step change: moving steps clears the message area,
                // so showing it first meant it was never actually seen.
                self.rootView.showNotice(VxLocalizables.Auth.codeSent)
            case .failure(let error):
                self.show(error)
            }
        }
    }

    private func acceptCode() {
        let code = rootView.codeText
        guard code.count >= 4 else {
            rootView.showError(VxLocalizables.Auth.errorInvalidCode)
            return
        }
        // The code is checked by the reset call itself; holding it here avoids
        // spending it twice.
        pendingCode = code
        step = .newPassword
    }

    private func saveNewPassword() {
        let password = rootView.passwordText
        guard !password.isEmpty else {
            rootView.showError(VxLocalizables.Auth.errorGeneric)
            return
        }

        rootView.isBusy = true

        // Two ways to reach this screen. Coming from a temporary password the
        // person is already signed in, so it is a change and not a reset —
        // reset would need a code they were never sent.
        if let current = passwordAwaitingChange {
            VxHub.shared.changePassword(current: current, new: password) { [weak self] result in
                guard let self else { return }
                self.rootView.isBusy = false
                switch result {
                case .success:
                    self.passwordAwaitingChange = nil
                    if let user = VxHub.shared.currentUser {
                        self.finish(.signedIn(user))
                    } else {
                        self.finish(.cancelled)
                    }
                case .failure(let error):
                    self.show(error)
                }
            }
            return
        }

        VxHub.shared.resetPassword(email: pendingEmail, code: pendingCode, newPassword: password) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                // Straight into the app rather than back to a form: the person
                // just proved both the address and the new password.
                self.passwordAwaitingChange = nil
                VxHub.shared.signIn(email: self.pendingEmail, password: password) { signIn in
                    self.handle(signIn)
                }
            case .failure(let error):
                self.show(error)
                // A rejected code belongs to the code step, not this one.
                if case .authFailed(let code, _) = error, code == "INVALID_CODE" {
                    self.step = .enterCode
                }
            }
        }
    }

    private func verifyEmailCode() {
        let code = rootView.codeText
        guard code.count >= 4 else {
            rootView.showError(VxLocalizables.Auth.errorInvalidCode)
            return
        }
        rootView.isBusy = true
        VxHub.shared.verifyEmail(code: code) { [weak self] result in
            guard let self else { return }
            self.rootView.isBusy = false
            switch result {
            case .success:
                if let user = VxHub.shared.currentUser {
                    self.finish(.signedIn(user))
                } else {
                    self.step = .signIn
                }
            case .failure(let error):
                self.show(error)
            }
        }
    }

    private func resendCode() {
        rootView.isBusy = true
        if step == .verifyEmail {
            VxHub.shared.resendVerificationCode { [weak self] result in
                self?.rootView.isBusy = false
                if case .failure(let error) = result { self?.show(error) }
                else { self?.rootView.showNotice(VxLocalizables.Auth.codeSent) }
            }
        } else {
            VxHub.shared.forgotPassword(email: pendingEmail) { [weak self] result in
                self?.rootView.isBusy = false
                if case .failure(let error) = result { self?.show(error) }
                else { self?.rootView.showNotice(VxLocalizables.Auth.codeSent) }
            }
        }
    }

    // MARK: - Providers

    private func signInWithGoogle() {
        rootView.isBusy = true
        VxHub.shared.signInWithGoogle(presenting: self) { [weak self] success, error in
            guard let self else { return }
            self.rootView.isBusy = false
            if success == true, let user = VxHub.shared.currentUser {
                self.finish(.signedIn(user))
            } else if success == true {
                // Accounts are off for this project: the device signed in, which
                // is all this app asked for.
                self.finish(.cancelled)
            } else if let error {
                self.showProviderError(error)
            }
        }
    }

    private func signInWithApple() {
        rootView.isBusy = true
        VxHub.shared.signInWithApple(presenting: self) { [weak self] success, error in
            guard let self else { return }
            self.rootView.isBusy = false
            if success == true, let user = VxHub.shared.currentUser {
                self.finish(.signedIn(user))
            } else if success == true {
                self.finish(.cancelled)
            } else if let error {
                self.showProviderError(error)
            }
        }
    }

    /**
     Reports a provider failure without quoting the system.

     Cancelling is the most common outcome and is not an error worth showing;
     anything else becomes our own sentence, because raw text like "The
     operation couldn't be completed. (…error 1001.)" is neither localized nor
     meaningful to the person reading it.
     */
    private func showProviderError(_ error: Error) {
        let nsError = error as NSError
        let cancelled = nsError.domain == ASAuthorizationError.errorDomain
            && nsError.code == ASAuthorizationError.canceled.rawValue
        let googleCancelled = nsError.domain.contains("GIDSignIn") && nsError.code == -5
        guard !cancelled, !googleCancelled else { return }
        rootView.showError(VxLocalizables.Auth.errorProviderUnavailable)
    }

    // MARK: - Results

    private func handle(_ result: Result<VxUser, VxHubError>) {
        rootView.isBusy = false
        switch result {
        case .success(let user):
            if user.mustChangePassword, passwordAwaitingChange != nil {
                step = .newPassword
                rootView.showNotice(VxLocalizables.Auth.mustChangePasswordNotice)
                return
            }
            finish(.signedIn(user))
        case .failure(let error):
            show(error)
        }
    }

    private func finish(_ result: VxAuthResult) {
        guard !hasFinished else { return }
        hasFinished = true
        let callback = onFinish
        onFinish = nil
        callback?(result)
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Validation and errors

    private func validate(email: String, password: String) -> Bool {
        guard isValidEmail(email) else {
            rootView.showError(VxLocalizables.Auth.errorGeneric)
            return false
        }
        let minimum = authConfig?.minPasswordLength ?? 8
        guard password.count >= minimum else {
            rootView.showError(String(format: VxLocalizables.Auth.errorPasswordTooShort, minimum))
            return false
        }
        return true
    }

    private func isValidEmail(_ email: String) -> Bool {
        // Deliberately loose: the server is the authority, and a strict regex
        // mostly rejects addresses that are in fact valid.
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        return trimmed.contains("@") && trimmed.contains(".") && trimmed.count >= 5
    }

    /// Turns the API's codes into something a person can act on.
    private func show(_ error: VxHubError) {
        rootView.isBusy = false

        guard case .authFailed(let code, let statusCode) = error else {
            rootView.showError(
                statusCodeIsOffline(error)
                    ? VxLocalizables.Auth.errorNetwork
                    : VxLocalizables.Auth.errorGeneric
            )
            return
        }

        if statusCode == 429 {
            rootView.showError(VxLocalizables.Auth.errorTooManyAttempts)
            return
        }

        // PASSWORD_TOO_SHORT carries the project's minimum after a colon.
        if code.hasPrefix("PASSWORD_TOO_SHORT") {
            let minimum = Int(code.split(separator: ":").last.map(String.init) ?? "") ?? 8
            rootView.showError(String(format: VxLocalizables.Auth.errorPasswordTooShort, minimum))
            return
        }

        switch code {
        case "INVALID_CREDENTIALS":
            rootView.showError(VxLocalizables.Auth.errorInvalidCredentials)
        case "EMAIL_ALREADY_REGISTERED":
            rootView.showError(VxLocalizables.Auth.errorEmailTaken)
        case "INVALID_CODE":
            rootView.showError(VxLocalizables.Auth.errorInvalidCode)
        case "EMAIL_NOT_VERIFIED":
            rootView.showError(VxLocalizables.Auth.errorEmailNotVerified)
        case "PASSWORD_TOO_SIMPLE":
            rootView.showError(VxLocalizables.Auth.errorPasswordTooSimple)
        case "ACCOUNT_UNAVAILABLE":
            // Banned or deleted. Telling this person to "try again" would send
            // them round the same loop until they hit the rate limit.
            rootView.showError(VxLocalizables.Auth.errorAccountUnavailable)
        case "AUTH_NOT_ENABLED", "PASSWORD_AUTH_NOT_ENABLED":
            rootView.showError(VxLocalizables.Auth.errorSignInUnavailable)
        case "NO_PASSWORD_SET":
            // They have an account, just not a password one — point at the
            // buttons that will work.
            rootView.showError(VxLocalizables.Auth.errorUsePasswordless)
        case "GOOGLE_LOGIN_NOT_ENABLED", "APPLE_LOGIN_NOT_ENABLED",
             "GOOGLE_LOGIN_NOT_CONFIGURED", "APPLE_LOGIN_NOT_CONFIGURED",
             "INVALID_GOOGLE_TOKEN", "INVALID_APPLE_TOKEN":
            rootView.showError(VxLocalizables.Auth.errorProviderUnavailable)
        default:
            rootView.showError(VxLocalizables.Auth.errorGeneric)
        }
    }

    private func statusCodeIsOffline(_ error: VxHubError) -> Bool {
        if case .networkUnavailable = error { return true }
        return false
    }
}
#endif
