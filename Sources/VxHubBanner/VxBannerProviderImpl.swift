#if os(iOS)
//
//  VxBannerProviderImpl.swift
//  VxHub
//
//  Created by VxHub on 2025.
//

import Foundation
import UIKit
import VxHubCore

public final class VxBannerProviderImpl: VxBannerProvider, @unchecked Sendable {

    public init() {}

    // MARK: - VxBannerProvider

    public func showBanner(_ message: String, type: VxBannerTypes, font: VxFont, buttonLabel: String?, action: (@Sendable () -> Void)?) {
        let model = VxBannerModel(
            id: UUID().uuidString,
            type: type,
            font: font,
            title: message,
            buttonLabel: buttonLabel,
            buttonAction: action
        )
        VxBannerManager.shared.addBannerToQuery(type: type, model: model)
    }

    public func dismissCurrentBanner() {
        VxBannerManager.shared.dismissCurrentBanner()
    }

    public func dismissAllBanners() {
        VxBannerManager.shared.dismissAllBanners()
    }
}
#endif
