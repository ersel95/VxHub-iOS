#if canImport(UIKit)
//
//  VxAuthConfiguration.swift
//  VxHub
//

import UIKit

/**
 Appearance of the ready-made authentication screens.

 Every value has a default that works on both light and dark, so an app can
 present the screens with `VxAuthConfiguration()` and only override what its
 brand needs.
 */
public struct VxAuthConfiguration: @unchecked Sendable {
    public let font: VxFont

    public let backgroundColor: UIColor
    public let titleColor: UIColor
    public let subtitleColor: UIColor

    public let fieldBackgroundColor: UIColor
    public let fieldTextColor: UIColor
    public let fieldPlaceholderColor: UIColor
    public let fieldBorderColor: UIColor
    public let fieldFocusedBorderColor: UIColor

    public let primaryButtonColor: UIColor
    public let primaryButtonTextColor: UIColor
    public let secondaryButtonTextColor: UIColor
    public let providerButtonBackgroundColor: UIColor
    public let providerButtonTextColor: UIColor
    public let providerButtonBorderColor: UIColor

    public let linkColor: UIColor
    public let errorColor: UIColor
    public let separatorColor: UIColor
    public let closeButtonTintColor: UIColor

    /// Shown above the title when set.
    public let logo: UIImage?
    /// Lets someone skip sign-in and keep using the app anonymously.
    public let showsGuestOption: Bool
    /// Shows the Terms and Privacy links the project configured.
    public let showsLegalLinks: Bool

    public init(
        font: VxFont = .rounded,
        backgroundColor: UIColor = .dynamicColor(light: .white, dark: .black),
        titleColor: UIColor = .dynamicColor(light: .black, dark: .white),
        subtitleColor: UIColor = .dynamicColor(light: UIColor.colorConverter("636973"), dark: UIColor.colorConverter("9E9E9E")),
        fieldBackgroundColor: UIColor = .dynamicColor(light: UIColor.colorConverter("F5F6F8"), dark: UIColor.colorConverter("1C1C1E")),
        fieldTextColor: UIColor = .dynamicColor(light: .black, dark: .white),
        fieldPlaceholderColor: UIColor = .dynamicColor(light: UIColor.colorConverter("9E9E9E"), dark: UIColor.colorConverter("6E6E73")),
        fieldBorderColor: UIColor = .dynamicColor(light: UIColor.colorConverter("E5E5EA"), dark: UIColor.colorConverter("2C2C2E")),
        fieldFocusedBorderColor: UIColor = .dynamicColor(light: .black, dark: .white),
        primaryButtonColor: UIColor = .dynamicColor(light: .black, dark: .white),
        primaryButtonTextColor: UIColor = .dynamicColor(light: .white, dark: .black),
        secondaryButtonTextColor: UIColor = .dynamicColor(light: .black, dark: .white),
        providerButtonBackgroundColor: UIColor = .dynamicColor(light: .white, dark: UIColor.colorConverter("1C1C1E")),
        providerButtonTextColor: UIColor = .dynamicColor(light: .black, dark: .white),
        providerButtonBorderColor: UIColor = .dynamicColor(light: UIColor.colorConverter("E5E5EA"), dark: UIColor.colorConverter("2C2C2E")),
        linkColor: UIColor = .dynamicColor(light: UIColor.colorConverter("0A84FF"), dark: UIColor.colorConverter("0A84FF")),
        errorColor: UIColor = .dynamicColor(light: UIColor.colorConverter("D70015"), dark: UIColor.colorConverter("FF453A")),
        separatorColor: UIColor = .dynamicColor(light: UIColor.colorConverter("E5E5EA"), dark: UIColor.colorConverter("2C2C2E")),
        closeButtonTintColor: UIColor = .dynamicColor(light: UIColor.colorConverter("636973"), dark: UIColor.colorConverter("9E9E9E")),
        logo: UIImage? = nil,
        showsGuestOption: Bool = false,
        showsLegalLinks: Bool = true
    ) {
        self.font = font
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.fieldBackgroundColor = fieldBackgroundColor
        self.fieldTextColor = fieldTextColor
        self.fieldPlaceholderColor = fieldPlaceholderColor
        self.fieldBorderColor = fieldBorderColor
        self.fieldFocusedBorderColor = fieldFocusedBorderColor
        self.primaryButtonColor = primaryButtonColor
        self.primaryButtonTextColor = primaryButtonTextColor
        self.secondaryButtonTextColor = secondaryButtonTextColor
        self.providerButtonBackgroundColor = providerButtonBackgroundColor
        self.providerButtonTextColor = providerButtonTextColor
        self.providerButtonBorderColor = providerButtonBorderColor
        self.linkColor = linkColor
        self.errorColor = errorColor
        self.separatorColor = separatorColor
        self.closeButtonTintColor = closeButtonTintColor
        self.logo = logo
        self.showsGuestOption = showsGuestOption
        self.showsLegalLinks = showsLegalLinks
    }
}

/// Which screen the flow is on.
public enum VxAuthStep: Sendable {
    case signIn
    case signUp
    case forgotPassword
    /// Code entry, for either a reset or an email verification.
    case enterCode
    case newPassword
    case verifyEmail
}

/// How the flow ended.
public enum VxAuthResult: Sendable {
    case signedIn(VxUser)
    case cancelled
    /// The person chose to keep using the app without an account.
    case continuedAsGuest
}
#endif
