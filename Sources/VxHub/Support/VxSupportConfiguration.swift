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
    let detailTicketBorderColor: UIColor
    let detailTicketDateColor: UIColor
    let detailSentBackgroundColor: UIColor
    let detailSentMessageColor: UIColor
    let detailSentDateColor: UIColor
    let detailSendImage: UIImage
    let detailPlaceholderColor: UIColor
    let detailHelpImage: UIImage
    let detailHelpColor: UIColor
    let ticketSheetBackgroundColor: UIColor
    let ticketSheetTextColor: UIColor
    
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
        detailTicketBorderColor: UIColor = UIColor.colorConverter("3C3C43"),
        detailTicketDateColor: UIColor = UIColor.colorConverter("808080"),
        detailSentBackgroundColor: UIColor = .white,
        detailSentMessageColor: UIColor = .black,
        detailSentDateColor: UIColor = UIColor.colorConverter("808080"),
        detailSendImage: UIImage? = nil,
        detailPlaceholderColor: UIColor = UIColor.colorConverter("333333"),
        detailHelpImage: UIImage? = nil,
        detailHelpColor: UIColor = UIColor.colorConverter("808080"),
        ticketSheetBackgroundColor: UIColor = .white,
        ticketSheetTextColor: UIColor = .black
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
        self.detailTicketBorderColor = detailTicketBorderColor
        self.detailTicketDateColor = detailTicketDateColor
        self.detailSentBackgroundColor = detailSentBackgroundColor
        self.detailSentMessageColor = detailSentMessageColor
        self.detailSentDateColor = detailSentDateColor
        self.detailSendImage = UIImage(named: "send_message_button_icon", in: .module, compatibleWith: nil)!
        self.detailPlaceholderColor = detailPlaceholderColor
        self.detailHelpImage = UIImage(named: "empty_messages_help_icon", in: .module, compatibleWith: nil)!
        self.detailHelpColor = detailHelpColor
        self.ticketSheetBackgroundColor = ticketSheetBackgroundColor
        self.ticketSheetTextColor = ticketSheetTextColor
    }
}
