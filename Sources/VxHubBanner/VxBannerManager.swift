#if os(iOS)
//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 27.02.2025.
//

import NotificationBannerSwift
import UIKit
import VxHubCore

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
            guard !bannerQueue.isEmpty else {
                self.isShowingBanner = false
                return
            }

            let model = bannerQueue[0]
            
            let customBanner = VxNotificationBannerView(
                model: model,
                buttonAction: model.buttonAction
            )
            
            let bannerView = NotificationBanner(customView: customBanner)
            
            var dynamicIslandHeight: CGFloat = 0
            if UIDevice.current.hasDynamicIsland == false && VxHub.shared.deviceBottomHeight == 0.0   { // No dynamic island no safe area
                dynamicIslandHeight = 0
            }else{
                dynamicIslandHeight = 24
            }
            let contentHeight: CGFloat = 64 + dynamicIslandHeight
            var labelHeight: CGFloat
            if model.buttonLabel == nil {
                labelHeight = model.title.localize().height(forConstrainedWidth: UIScreen.main.bounds.width - 98, font: VxFontManager.shared.font(font: model.font, size: 12))
            } else {
                labelHeight = model.title.localize().height(forConstrainedWidth: UIScreen.main.bounds.width - 168, font: VxFontManager.shared.font(font: model.font, size: 12))
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
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard !bannerQueue.isEmpty else { return }
            self.bannerQueue.removeFirst()
        }
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
            guard bannerQueue.isEmpty == false else {
                return
            }
            self.isShowingBanner = true
            self.showNextBanner()
        }
    }
}
#endif

