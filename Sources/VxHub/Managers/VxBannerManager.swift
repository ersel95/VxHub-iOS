//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 27.02.2025.
//

import NotificationBannerSwift
import UIKit

// MARK: - Types
public struct VxBannerModel: @unchecked Sendable {
    let id: String
    let type: VxBannerTypes
    let font: VxPaywallFont
    let title: String
    let buttonLabel: String?
    var buttonAction: (@Sendable () -> Void)?
    
    public init(id: String,
                type: VxBannerTypes,
                font: VxPaywallFont,
                title: String,
                buttonLabel: String? = nil,
                buttonAction: (@Sendable () -> Void)? = nil) {
        self.id = id
        self.type = type
        self.font = font
        self.title = title
        self.buttonLabel = buttonLabel
        self.buttonAction = buttonAction
    }
}

public enum VxBannerTypes: Sendable  {
    case success
    case error
    case warning
    case info
    case debug
    
    var backgroundColor: UIColor {
        switch self {
        case .success: return UIColor(red: 57/255, green: 198/255, blue: 117/255, alpha: 1)
        case .error: return UIColor(red: 220/255, green: 38/255, blue: 38/255, alpha: 1)
        case .warning: return UIColor(red: 234/255, green: 179/255, blue: 8/255, alpha: 1)
        case .info: return UIColor(red: 59/255, green: 130/255, blue: 246/255, alpha: 1)
        case .debug: return UIColor.black.withAlphaComponent(0.9)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .debug: return .white
        default: return .white
        }
    }
    
    var iconName: String {
        switch self {
        case .success: return "checkmark.circle"
        case .error: return "xmark.circle"
        case .warning: return "exclamationmark.triangle"
        case .info: return "info.circle"
        case .debug: return "magnifyingglass.circle"
        }
    }
}

public final class VxBannerManager: @unchecked Sendable {
    
    public static nonisolated let shared = VxBannerManager()
    private init() {}
    
    internal var currentVxBanner: VxNotificationBannerView?
    internal var currentBanner: NotificationBanner?
    
    private var bannerQueue: [VxBannerModel] = [] {
        didSet {
            guard bannerQueue.isEmpty == false else {
                self.isShowingBanner = false
                return
            }
            guard isShowingBanner == false else { return }
            self.isShowingBanner = true
            self.showNextBanner()
        }
    }
    private var isShowingBanner: Bool = false
    
    public func addBannerToQuery(type: VxBannerTypes,
                                 model: VxBannerModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if let currentVxBanner,
               currentVxBanner.descriptionTitleLabel.text == model.title {
                return
            }
            
            if bannerQueue.contains(where: {$0.title == model.title && $0.type == model.type }) {
                return
            }
            
            bannerQueue.append(model)
        }
    }
    
    private func showNextBanner() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let model = bannerQueue[0]
            
            let customBanner = VxNotificationBannerView(
                model: model,
                buttonAction: model.buttonAction
            )
            
            let bannerView = NotificationBanner(customView: customBanner)
            
            var dynamicIslandHeight: CGFloat = 0
            if UIScreen.main.bounds.height <= 667 { // No dynamic island no safe area
                dynamicIslandHeight = 0
            }else{
                dynamicIslandHeight = 24
            }
            let contentHeight: CGFloat = 64 + dynamicIslandHeight
            var labelHeight: CGFloat
            if model.buttonLabel == nil {
                labelHeight = model.title.localize().height(forConstrainedWidth: UIScreen.main.bounds.width - 98, font: VxFontManager.shared.font(font: model.font, size: 12))
            } else {
                labelHeight = model.title.localize().height(forConstrainedWidth: UIScreen.main.bounds.width - 158, font: VxFontManager.shared.font(font: model.font, size: 12))
            }
            
            var height: CGFloat
            if contentHeight + labelHeight < 80 + dynamicIslandHeight {
                height = 80 + dynamicIslandHeight
            } else {
                height = (contentHeight + labelHeight) + dynamicIslandHeight
            }
            
            bannerView.bannerHeight = height
            bannerView.delegate = self
            bannerView.haptic = .light
            bannerView.duration = 3.0
            bannerView.autoDismiss = true
            
            self.currentBanner = bannerView
            self.currentVxBanner = customBanner
            bannerView.show()
        }
    }
    
    public func dismissCurrentBanner() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if !bannerQueue.isEmpty {
                bannerQueue.removeFirst()
            }
            currentBanner?.dismiss()
        }
    }
    
    public func dismissAllBanners() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            bannerQueue.removeAll()
            isShowingBanner = false
            NotificationBannerQueue.default.dismissAllForced()
            NotificationBannerQueue.default.removeAll()
        }
    }
}

extension VxBannerManager: NotificationBannerDelegate {
    public func notificationBannerWillAppear(_ banner: NotificationBannerSwift.BaseNotificationBanner) {
        self.bannerQueue.removeFirst()
        return
    }
    
    public func notificationBannerDidAppear(_ banner: NotificationBannerSwift.BaseNotificationBanner) {
        return
    }
    
    public func notificationBannerWillDisappear(_ banner: NotificationBannerSwift.BaseNotificationBanner) {
        return
    }
    
    public func notificationBannerDidDisappear(_ banner: NotificationBannerSwift.BaseNotificationBanner) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.currentBanner = nil
            self.currentVxBanner = nil
            self.isShowingBanner = false
            
            if !bannerQueue.isEmpty {
                bannerQueue.removeFirst()
            }
        }
    }
    
    
}

