#if os(iOS)
//
//  VxAppsFlyerProvider.swift
//  VxHub
//
//  Created by VxHub on 2025.
//

import Foundation
import VxHubCore
import AppsFlyerLib

public final class VxAppsFlyerProvider: NSObject, VxAttributionProvider, @unchecked Sendable {

    private weak var vxDelegate: (any VxAttributionDelegate)?

    public override init() {
        super.init()
    }

    // MARK: - VxAttributionProvider

    public var attributionUID: String {
        return AppsFlyerLib.shared().getAppsFlyerUID()
    }

    public func initialize(
        devKey: String,
        appID: String,
        delegate: any VxAttributionDelegate,
        customerUserID: String,
        currentDeviceLanguage: String
    ) {
        self.vxDelegate = delegate
        AppsFlyerLib.shared().appsFlyerDevKey = devKey
        AppsFlyerLib.shared().appleAppID = appID
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        AppsFlyerLib.shared().customerUserID = customerUserID
        AppsFlyerLib.shared().shouldCollectDeviceName = true
        AppsFlyerLib.shared().currentDeviceLanguage = currentDeviceLanguage
        AppsFlyerLib.shared().delegate = self
    }

    public func start() {
        AppsFlyerLib.shared().start()
    }

    public func logEvent(eventName: String, values: [String: Any]?) {
        AppsFlyerLib.shared().logEvent(eventName, withValues: values)
    }

    public func changeVid(customerUserID: String) {
        AppsFlyerLib.shared().customerUserID = customerUserID
    }
}

// MARK: - AppsFlyerLibDelegate

extension VxAppsFlyerProvider: AppsFlyerLibDelegate {
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        let networkManager = VxNetworkManager()
        networkManager.sendConversationData(conversionInfo)
        self.vxDelegate?.onConversionDataSuccess(conversionInfo)
    }

    public func onConversionDataFail(_ error: any Error) {
        self.vxDelegate?.onConversionDataFail(error)
    }
}
#endif
