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
    let tabbarHeight: CGFloat?
    
    public init(
        font: VxPaywallFont = .rounded,
        backgroundColor: UIColor = .black,
        navigationTintColor: UIColor = .white,
        listingActionColor: UIColor = .white,
        listingActionTextColor: UIColor = .black,
        listingItemTitleColor: UIColor = .white,
        listingDescriptionColor: UIColor = UIColor.colorConverter("808080"),
        listingDateColor: UIColor = UIColor.colorConverter("808080"),
        listingUnreadColor: UIColor = .white,
        detailAdminTicketBorderColor: UIColor = UIColor.colorConverter("3C3C43"),
        detailAdminTicketBackgroundColor: UIColor = .black,
        detailAdminTicketMessageColor: UIColor = .white,
        detailAdminTicketDateColor: UIColor = UIColor.colorConverter("808080"),
        detailUserTicketBackgroundColor: UIColor = .white,
        detailUserTicketMessageColor: UIColor = .black,
        detailUserTicketDateColor: UIColor = UIColor.colorConverter("808080"),
        detailSendButtonActiveImage: UIImage? = nil,
        detailPlaceholderColor: UIColor = UIColor.colorConverter("333333"),
        detailHelpImage: UIImage? = nil,
        detailHelpColor: UIColor = UIColor.colorConverter("808080"),
        ticketSheetBackgroundColor: UIColor = UIColor.colorConverter("111111"),
        ticketSheetTextColor: UIColor = .white,
        ticketSheetLineColor: UIColor = UIColor.colorConverter("1C1C1C"),
        ticketSheetShadowColor: UIColor = UIColor.colorConverter("838383"),
        messageTextFieldBackgroundColor: UIColor = UIColor.colorConverter("0E0E0E"),
        messageTextFieldTextColor: UIColor = .white,
        headerLineViewColor: UIColor = UIColor.colorConverter("1C1C1C"),
        tabbarHeight: CGFloat? = nil
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
        self.detailSendButtonActiveImage = detailSendButtonActiveImage ?? UIImage(named: "send_message_button_icon", in: .module, compatibleWith: nil)!
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
        self.tabbarHeight = tabbarHeight
    }
}
