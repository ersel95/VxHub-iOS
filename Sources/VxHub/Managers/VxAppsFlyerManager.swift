//
//  File.swift
//  VxHub
//
//  Created by furkan on 1.11.2024.
//

import Foundation
import AppsFlyerLib

public protocol VxAppsFlyerDelegate : Sendable, AnyObject {
    func onConversionDataSuccess(_ info: [AnyHashable: Any])
    func onConversionDataFail(_ error: any Error)
}

open class VxAppsFlyerManager: NSObject, @unchecked Sendable {
    
    public static let shared = VxAppsFlyerManager()
    weak var vxAppsFlyerDelegate: VxAppsFlyerDelegate?
    
    public var appsflyerUID: String {
        return AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    public func start() {
        AppsFlyerLib.shared().start()
    }
    
    public func logAppsFlyerEvent(eventName: String, values: [String: Any]?) {
        AppsFlyerLib.shared().logEvent(eventName, withValues: values)
    }
    
    open func initialize(
        appsFlyerDevKey: String,
        appleAppID: String,
        delegate: VxAppsFlyerDelegate,
        timeoutInterval: TimeInterval = 60,
        customerUserID: String,
        shouldCollectDeviceName: Bool = true,
        currentDeviceLanguage: String
    ) {
        AppsFlyerLib.shared().appsFlyerDevKey = appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = appleAppID
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: timeoutInterval)
        AppsFlyerLib.shared().customerUserID = customerUserID
        AppsFlyerLib.shared().shouldCollectDeviceName = shouldCollectDeviceName
        AppsFlyerLib.shared().currentDeviceLanguage = currentDeviceLanguage
        AppsFlyerLib.shared().delegate = self
    }
}

extension VxAppsFlyerManager : AppsFlyerLibDelegate {
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        conversionInfo
        self.vxAppsFlyerDelegate?.onConversionDataSuccess(conversionInfo)
    }
    
    public func onConversionDataFail(_ error: any Error) {
        self.vxAppsFlyerDelegate?.onConversionDataFail(error)
    }
}
