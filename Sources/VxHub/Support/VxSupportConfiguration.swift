//
//  VxSupportConfiguration.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 4.02.2025.
//

import UIKit

public struct VxSupportConfiguration: @unchecked Sendable {
    let font: VxPaywallFont
    let backgroundColor: UIColor
    let navigationTintColor: UIColor
    let listingActionColor: UIColor
    let listingActionTextColor: UIColor
    let listingItemTitleColor: UIColor
    let listingDescriptionColor: UIColor
    let listingDateColor: UIColor
    let listingUnreadColor: UIColor
    let detailAdminTicketBorderColor: UIColor
    let detailAdminTicketBackgroundColor: UIColor
    let detailAdminTicketMessageColor: UIColor
    let detailAdminTicketDateColor: UIColor
    let detailUserTicketBackgroundColor: UIColor
    let detailUserTicketMessageColor: UIColor
    let detailUserTicketDateColor: UIColor
    let detailSendButtonActiveImage: UIImage
    let detailPlaceholderColor: UIColor
    let detailHelpImage: UIImage
    let detailHelpColor: UIColor
    let ticketSheetBackgroundColor: UIColor
    let ticketSheetTextColor: UIColor
    let ticketSheetLineColor: UIColor
    let ticketSheetShadowColor: UIColor
    let messageTextFieldBackgroundColor: UIColor
    let messageTextFieldTextColor: UIColor
    let headerLineViewColor: UIColor
    let bottomLineViewColor: UIColor
    let messageBarBackgroundColor: UIColor
    
    public init(
        font: VxPaywallFont = .rounded,
        backgroundColor: UIColor = .dynamicColor(light: .white, dark: .black),
        navigationTintColor: UIColor = .dynamicColor(light: .black, dark: .white),
        listingActionColor: UIColor = .dynamicColor(light: .black, dark: .white),
        listingActionTextColor: UIColor = .dynamicColor(light: .white, dark: .black),
        listingItemTitleColor: UIColor = .dynamicColor(light: .black, dark: .white),
        listingDescriptionColor: UIColor = .dynamicColor(light: UIColor.colorConverter("636973"), dark: UIColor.colorConverter("808080")),
        listingDateColor: UIColor = .dynamicColor(light: UIColor.colorConverter("9E9E9E"), dark: UIColor.colorConverter("808080")),
        listingUnreadColor: UIColor = .dynamicColor(light: .black, dark: .white),
        detailAdminTicketBorderColor: UIColor = .dynamicColor(light: UIColor.colorConverter("E9EBF0"), dark: UIColor.colorConverter("3C3C43")),
        detailAdminTicketBackgroundColor: UIColor = .dynamicColor(light: .white, dark: .black),
        detailAdminTicketMessageColor: UIColor = .dynamicColor(light: .black, dark: .white),
        detailAdminTicketDateColor: UIColor = .dynamicColor(light: UIColor.colorConverter("9E9E9E"), dark: UIColor.colorConverter("808080")),
        detailUserTicketBackgroundColor: UIColor = .dynamicColor(light: UIColor.colorConverter("478AFF"), dark: .white),
        detailUserTicketMessageColor: UIColor = .dynamicColor(light: .white, dark: .black),
        detailUserTicketDateColor: UIColor = .dynamicColor(light: UIColor.colorConverter("FFD8F0"), dark: UIColor.colorConverter("808080")),
        detailSendButtonActiveImage: UIImage? = nil,
        detailPlaceholderColor: UIColor = .dynamicColor(light: UIColor.colorConverter("636973"), dark: UIColor.colorConverter("333333")),
        detailHelpImage: UIImage? = nil,
        detailHelpColor: UIColor = .dynamicColor(light: UIColor.colorConverter("636973"), dark: UIColor.colorConverter("808080")),
        ticketSheetBackgroundColor: UIColor = .dynamicColor(light: UIColor.colorConverter("E9EBF0"), dark: UIColor.colorConverter("111111")),
        ticketSheetTextColor: UIColor = .dynamicColor(light: .black, dark: .white),
        ticketSheetLineColor: UIColor = .dynamicColor(light: UIColor.colorConverter("E9EBF0"), dark: UIColor.colorConverter("1C1C1C")),
        ticketSheetShadowColor: UIColor = .dynamicColor(light: UIColor.colorConverter("636973"), dark: UIColor.colorConverter("838383")),
        messageTextFieldBackgroundColor: UIColor = .dynamicColor(light: UIColor.colorConverter("E9EBF0"), dark: UIColor.colorConverter("0E0E0E")),
        messageTextFieldTextColor: UIColor = .dynamicColor(light: .black, dark: .white),
        headerLineViewColor: UIColor = .dynamicColor(light: UIColor.colorConverter("E9EBF0"), dark: UIColor.colorConverter("1C1C1C")),
        bottomLineViewColor: UIColor = .dynamicColor(light: UIColor.colorConverter("E9EBF0"), dark: UIColor.colorConverter("131313")),
        messageBarBackgroundColor: UIColor = .dynamicColor(light: .white, dark: .black)
    ) {
        self.font = font
        self.backgroundColor = backgroundColor
        self.navigationTintColor = navigationTintColor
        self.listingActionColor = listingActionColor
        self.listingActionTextColor = listingActionTextColor
        self.listingItemTitleColor = listingItemTitleColor
        self.listingDescriptionColor = listingDescriptionColor
        self.listingDateColor = listingDateColor
        self.listingUnreadColor = listingUnreadColor
        self.detailAdminTicketBorderColor = detailAdminTicketBorderColor
        self.detailAdminTicketBackgroundColor = detailAdminTicketBackgroundColor
        self.detailAdminTicketMessageColor = detailAdminTicketMessageColor
        self.detailAdminTicketDateColor = detailAdminTicketDateColor
        self.detailUserTicketBackgroundColor = detailUserTicketBackgroundColor
        self.detailUserTicketMessageColor = detailUserTicketMessageColor
        self.detailUserTicketDateColor = detailUserTicketDateColor
        self.detailSendButtonActiveImage = detailSendButtonActiveImage ?? UIImage.dynamicImage(light: UIImage(named: "light_send_message_button_icon", in: .module, compatibleWith: nil), dark: UIImage(named: "send_message_button_icon", in: .module, compatibleWith: nil))!
        self.detailPlaceholderColor = detailPlaceholderColor
        self.detailHelpImage = detailHelpImage ?? UIImage(named: "empty_messages_help_icon", in: .module, compatibleWith: nil)!
        self.detailHelpColor = detailHelpColor
        self.ticketSheetBackgroundColor = ticketSheetBackgroundColor
        self.ticketSheetTextColor = ticketSheetTextColor
        self.ticketSheetLineColor = ticketSheetLineColor
        self.ticketSheetShadowColor = ticketSheetShadowColor
        self.messageTextFieldBackgroundColor = messageTextFieldBackgroundColor
        self.messageTextFieldTextColor = messageTextFieldTextColor
        self.headerLineViewColor = headerLineViewColor
        self.bottomLineViewColor = bottomLineViewColor
        self.messageBarBackgroundColor = messageBarBackgroundColor
    }
}
