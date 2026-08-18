#if canImport(UIKit)
//
//  VxAuthViewController.swift
//  VxHub
//

import UIKit

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
    private let onFinish: ((VxAuthResult) -> Void)?

    private var step: VxAuthStep {
        didSet { applyStep(animated: true) }
    }

    /// Held between steps: the address a code was sent to, and the code itself.
    private var pendingEmail: String = ""
    private var pendingCode: String = ""

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
        onFinish: ((VxAuthResult) -> Void)? = nil,
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
            queue: .main,
        ) { [weak self] _ in
            guard let self else { return }
            self.applyStep(animated: true)
        }
    }

    // MARK: - Wiring

    private func wireActions() {
        rootView.onPrimaryTapped = { [weak self] in self?.submit() }
        rootView.onSecondaryTapped = { [weak self] in self?.toggleSignInSignUp() }
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
            animated: animated,
        )
    }

    private func toggleSignInSignUp() {
        step = (step == .signIn) ? .signUp : .signIn
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
                self.rootView.showNotice(VxLocalizables.Auth.codeSent)
                self.step = .enterCode
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
        VxHub.shared.resetPassword(email: pendingEmail, code: pendingCode, newPassword: password) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                // Straight into the app rather than back to a form: the person
                // just proved both the address and the new password.
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
                self.rootView.showError(error.localizedDescription)
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
                self.rootView.showError(error.localizedDescription)
            }
        }
    }

    // MARK: - Results

    private func handle(_ result: Result<VxUser, VxHubError>) {
        rootView.isBusy = false
        switch result {
        case .success(let user):
            finish(.signedIn(user))
        case .failure(let error):
            show(error)
        }
    }

    private func finish(_ result: VxAuthResult) {
        onFinish?(result)
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
                    : VxLocalizables.Auth.errorGeneric,
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
