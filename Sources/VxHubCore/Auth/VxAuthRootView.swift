#if canImport(UIKit)
//
//  VxAuthRootView.swift
//  VxHub
//

import UIKit

/**
 The form behind every step of the sign-in flow.

 A single view whose fields and copy change per step, rather than a screen each:
 the transitions are mostly the same form gaining or losing a field, and keeping
 one view means the keyboard never dismisses between them.
 */
internal final class VxAuthRootView: UIView {

    // MARK: - Callbacks

    var onPrimaryTapped: (() -> Void)?
    var onSecondaryTapped: (() -> Void)?
    var onForgotTapped: (() -> Void)?
    var onCloseTapped: (() -> Void)?
    var onGuestTapped: (() -> Void)?
    var onGoogleTapped: (() -> Void)?
    var onAppleTapped: (() -> Void)?
    var onResendTapped: (() -> Void)?

    // MARK: - State

    private let configuration: VxAuthConfiguration

    var isBusy: Bool = false {
        didSet { updateBusyState() }
    }

    var emailText: String { emailField.text?.trimmingCharacters(in: .whitespaces) ?? "" }
    var passwordText: String { passwordField.text ?? "" }
    var nameText: String? {
        let value = nameField.text?.trimmingCharacters(in: .whitespaces)
        return (value?.isEmpty ?? true) ? nil : value
    }
    var codeText: String { codeField.text?.trimmingCharacters(in: .whitespaces) ?? "" }

    // MARK: - Views

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private lazy var closeButton = UIButton(type: .system)
    private let logoView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private lazy var nameField = makeField(placeholder: VxLocalizables.Auth.namePlaceholder)
    private lazy var emailField = makeField(placeholder: VxLocalizables.Auth.emailPlaceholder, keyboard: .emailAddress)
    private lazy var passwordField = makeField(placeholder: VxLocalizables.Auth.passwordPlaceholder, secure: true)
    private lazy var codeField = makeField(placeholder: "000000", keyboard: .numberPad)

    private let messageLabel = UILabel()
    private let primaryButton = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let forgotButton = UIButton(type: .system)
    private let resendButton = UIButton(type: .system)

    private let separatorStack = UIStackView()
    private let googleButton = UIButton(type: .system)
    private let appleButton = UIButton(type: .system)

    private let secondaryButton = UIButton(type: .system)
    private let guestButton = UIButton(type: .system)
    private let legalLabel = UILabel()

    // MARK: - Init

    init(configuration: VxAuthConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        buildHierarchy()
        style()
        wire()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: - Layout

    private func buildHierarchy() {
        backgroundColor = configuration.backgroundColor

        addSubview(scrollView)
        scrollView.addSubview(contentStack)
        addSubview(closeButton)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.alignment = .fill

        [logoView, titleLabel, subtitleLabel, nameField, emailField, passwordField, codeField,
         messageLabel, primaryButton, forgotButton, resendButton, separatorStack,
         googleButton, appleButton, secondaryButton, guestButton, legalLabel]
            .forEach { contentStack.addArrangedSubview($0) }

        primaryButton.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 44),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),

            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            logoView.heightAnchor.constraint(equalToConstant: 44),
            primaryButton.heightAnchor.constraint(equalToConstant: 52),
            googleButton.heightAnchor.constraint(equalToConstant: 52),
            appleButton.heightAnchor.constraint(equalToConstant: 52),

            spinner.centerXAnchor.constraint(equalTo: primaryButton.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: primaryButton.centerYAnchor),
        ])

        [nameField, emailField, passwordField, codeField].forEach {
            $0.heightAnchor.constraint(equalToConstant: 52).isActive = true
        }
    }

    private func style() {
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = configuration.closeButtonTintColor

        logoView.image = configuration.logo
        logoView.contentMode = .scaleAspectFit
        logoView.isHidden = configuration.logo == nil

        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = configuration.titleColor
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.textColor = configuration.subtitleColor
        subtitleLabel.numberOfLines = 0

        // Reserved space so the layout does not jump when an error appears.
        messageLabel.font = .systemFont(ofSize: 13)
        messageLabel.numberOfLines = 0
        messageLabel.textColor = configuration.errorColor
        messageLabel.isHidden = true

        primaryButton.backgroundColor = configuration.primaryButtonColor
        primaryButton.setTitleColor(configuration.primaryButtonTextColor, for: .normal)
        primaryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        primaryButton.layer.cornerRadius = 12
        spinner.color = configuration.primaryButtonTextColor
        spinner.hidesWhenStopped = true

        [forgotButton, secondaryButton, guestButton, resendButton].forEach {
            $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            $0.setTitleColor(configuration.linkColor, for: .normal)
        }
        secondaryButton.setTitleColor(configuration.secondaryButtonTextColor, for: .normal)
        guestButton.setTitleColor(configuration.subtitleColor, for: .normal)

        styleProviderButton(googleButton, title: VxLocalizables.Auth.googleButton, systemImage: "g.circle")
        styleProviderButton(appleButton, title: VxLocalizables.Auth.appleButton, systemImage: "apple.logo")

        separatorStack.axis = .horizontal
        separatorStack.alignment = .center
        separatorStack.spacing = 12
        let left = UIView(), right = UIView()
        let separatorLabel = UILabel()
        separatorLabel.text = VxLocalizables.Auth.separator
        separatorLabel.font = .systemFont(ofSize: 13)
        separatorLabel.textColor = configuration.subtitleColor
        [left, right].forEach {
            $0.backgroundColor = configuration.separatorColor
            $0.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        separatorStack.addArrangedSubview(left)
        separatorStack.addArrangedSubview(separatorLabel)
        separatorStack.addArrangedSubview(right)
        left.widthAnchor.constraint(equalTo: right.widthAnchor).isActive = true

        legalLabel.font = .systemFont(ofSize: 11)
        legalLabel.textColor = configuration.subtitleColor
        legalLabel.numberOfLines = 0
        legalLabel.textAlignment = .center
        legalLabel.text = VxLocalizables.Auth.legalNotice
        legalLabel.isHidden = !configuration.showsLegalLinks

        contentStack.setCustomSpacing(6, after: titleLabel)
        contentStack.setCustomSpacing(24, after: subtitleLabel)
        contentStack.setCustomSpacing(20, after: primaryButton)
        contentStack.setCustomSpacing(20, after: separatorStack)
    }

    private func styleProviderButton(_ button: UIButton, title: String, systemImage: String) {
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: systemImage), for: .normal)
        button.tintColor = configuration.providerButtonTextColor
        button.setTitleColor(configuration.providerButtonTextColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = configuration.providerButtonBackgroundColor
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = configuration.providerButtonBorderColor.cgColor
        button.configuration = nil
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
    }

    private func makeField(placeholder: String, keyboard: UIKeyboardType = .default, secure: Bool = false) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.keyboardType = keyboard
        field.isSecureTextEntry = secure
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.backgroundColor = configuration.fieldBackgroundColor
        field.textColor = configuration.fieldTextColor
        field.font = .systemFont(ofSize: 16)
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = configuration.fieldBorderColor.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        field.leftViewMode = .always
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: configuration.fieldPlaceholderColor],
        )
        // Lets iOS offer the saved password and the emailed code from the keyboard.
        if secure {
            field.textContentType = .password
        } else if keyboard == .emailAddress {
            field.textContentType = .username
        } else if keyboard == .numberPad {
            field.textContentType = .oneTimeCode
        }
        return field
    }

    private func wire() {
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)
        forgotButton.addTarget(self, action: #selector(forgotTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        guestButton.addTarget(self, action: #selector(guestTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleTapped), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(resendTapped), for: .touchUpInside)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }

    // MARK: - Rendering

    func render(step: VxAuthStep, authConfig: VxAuthConfig?, email: String, animated: Bool) {
        let passwordAvailable = authConfig?.passwordEnabled ?? true
        let googleAvailable = authConfig?.googleEnabled ?? false
        let appleAvailable = authConfig?.appleEnabled ?? false
        // Providers only belong on the first screen; inside a reset flow they
        // would take the person out of what they were doing.
        let onEntryScreen = step == .signIn || step == .signUp

        let apply = {
            switch step {
            case .signIn:
                self.titleLabel.text = VxLocalizables.Auth.signInTitle
                self.subtitleLabel.text = VxLocalizables.Auth.signInSubtitle
                self.primaryButton.setTitle(VxLocalizables.Auth.signInButton, for: .normal)
                self.secondaryButton.setTitle(VxLocalizables.Auth.noAccountPrompt, for: .normal)
                self.forgotButton.setTitle(VxLocalizables.Auth.forgotPrompt, for: .normal)
            case .signUp:
                self.titleLabel.text = VxLocalizables.Auth.signUpTitle
                self.subtitleLabel.text = VxLocalizables.Auth.signUpSubtitle
                self.primaryButton.setTitle(VxLocalizables.Auth.signUpButton, for: .normal)
                self.secondaryButton.setTitle(VxLocalizables.Auth.hasAccountPrompt, for: .normal)
            case .forgotPassword:
                self.titleLabel.text = VxLocalizables.Auth.forgotTitle
                self.subtitleLabel.text = VxLocalizables.Auth.forgotSubtitle
                self.primaryButton.setTitle(VxLocalizables.Auth.sendCodeButton, for: .normal)
                self.secondaryButton.setTitle(VxLocalizables.Auth.hasAccountPrompt, for: .normal)
            case .enterCode, .verifyEmail:
                self.titleLabel.text = step == .verifyEmail
                    ? VxLocalizables.Auth.verifyTitle
                    : VxLocalizables.Auth.codeTitle
                self.subtitleLabel.text = String(format: VxLocalizables.Auth.codeSubtitle, email)
                self.primaryButton.setTitle(VxLocalizables.Auth.continueButton, for: .normal)
                self.resendButton.setTitle(VxLocalizables.Auth.resendCodeButton, for: .normal)
            case .newPassword:
                self.titleLabel.text = VxLocalizables.Auth.newPasswordTitle
                self.subtitleLabel.text = nil
                self.primaryButton.setTitle(VxLocalizables.Auth.savePasswordButton, for: .normal)
                self.passwordField.attributedPlaceholder = NSAttributedString(
                    string: VxLocalizables.Auth.newPasswordPlaceholder,
                    attributes: [.foregroundColor: self.configuration.fieldPlaceholderColor],
                )
                self.passwordField.textContentType = .newPassword
            }

            self.nameField.isHidden = step != .signUp
            self.emailField.isHidden = !(step == .signIn || step == .signUp || step == .forgotPassword)
            self.passwordField.isHidden = !(step == .signIn || step == .signUp || step == .newPassword)
            self.codeField.isHidden = !(step == .enterCode || step == .verifyEmail)
            self.forgotButton.isHidden = step != .signIn || !passwordAvailable
            self.resendButton.isHidden = !(step == .enterCode || step == .verifyEmail)
            self.secondaryButton.isHidden = !(step == .signIn || step == .signUp || step == .forgotPassword)
            self.subtitleLabel.isHidden = self.subtitleLabel.text == nil

            let showsProviders = onEntryScreen && (googleAvailable || appleAvailable)
            self.googleButton.isHidden = !(onEntryScreen && googleAvailable)
            self.appleButton.isHidden = !(onEntryScreen && appleAvailable)
            // Only meaningful when there is something to separate password
            // sign-in from.
            self.separatorStack.isHidden = !(showsProviders && passwordAvailable)

            // A project with no password sign-in shows providers alone.
            if !passwordAvailable && onEntryScreen {
                self.emailField.isHidden = true
                self.passwordField.isHidden = true
                self.nameField.isHidden = true
                self.primaryButton.isHidden = true
                self.secondaryButton.isHidden = true
            } else {
                self.primaryButton.isHidden = false
            }

            self.guestButton.isHidden = !(self.configuration.showsGuestOption && onEntryScreen)
            self.guestButton.setTitle(VxLocalizables.Auth.guestButton, for: .normal)
            self.legalLabel.isHidden = !self.configuration.showsLegalLinks || !onEntryScreen

            self.messageLabel.isHidden = true
            self.codeField.text = nil
        }

        guard animated else {
            apply()
            return
        }
        UIView.animate(withDuration: 0.22) {
            apply()
            self.layoutIfNeeded()
        }
    }

    // MARK: - Feedback

    func showError(_ message: String) {
        messageLabel.textColor = configuration.errorColor
        messageLabel.text = message
        messageLabel.isHidden = false
    }

    func showNotice(_ message: String) {
        messageLabel.textColor = configuration.subtitleColor
        messageLabel.text = message
        messageLabel.isHidden = false
    }

    func clearError() {
        messageLabel.isHidden = true
        messageLabel.text = nil
    }

    private func updateBusyState() {
        primaryButton.isEnabled = !isBusy
        primaryButton.setTitleColor(
            isBusy ? .clear : configuration.primaryButtonTextColor,
            for: .normal,
        )
        isBusy ? spinner.startAnimating() : spinner.stopAnimating()
        [googleButton, appleButton, secondaryButton, forgotButton, resendButton].forEach {
            $0.isEnabled = !isBusy
        }
    }

    // MARK: - Actions

    @objc private func primaryTapped() { onPrimaryTapped?() }
    @objc private func secondaryTapped() { onSecondaryTapped?() }
    @objc private func forgotTapped() { onForgotTapped?() }
    @objc private func closeTapped() { onCloseTapped?() }
    @objc private func guestTapped() { onGuestTapped?() }
    @objc private func googleTapped() { onGoogleTapped?() }
    @objc private func appleTapped() { onAppleTapped?() }
    @objc private func resendTapped() { onResendTapped?() }
    @objc private func dismissKeyboard() { endEditing(true) }
}
#endif
