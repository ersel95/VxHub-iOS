//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 6.01.2025.
//

import VxHubCore
import Sentry

internal struct VxSentryManager {
    private let defaultConfig = VxSentryConfig(
        environment: VxHub.shared.config?.environment ?? .stage,
        enableDebug: false,
        tracesSampleRate: 1.0,
        profilesSampleRate: 1.0,
        attachScreenshot: false,
        attachViewHierarchy: false
    )
    
    internal init() {}
    
    internal func start(
        dsn: String,
        config: VxSentryConfig? = nil
    ) {
            let sentryConfig = config ?? defaultConfig
            SentrySDK.start { options in
                options.dsn = dsn
                options.debug = sentryConfig.enableDebug
                options.environment = sentryConfig.environment
                options.tracesSampleRate = NSNumber(value: sentryConfig.tracesSampleRate)
                options.profilesSampleRate = NSNumber(value: sentryConfig.profilesSampleRate)
                #if canImport(UIKit)
                options.attachScreenshot = sentryConfig.attachScreenshot
                options.attachViewHierarchy = sentryConfig.attachViewHierarchy
                #endif
            }
            let user = User()
            user.userId = VxHub.shared.deviceId
            SentrySDK.setUser(user)
        }
    
    internal func stop() {
        SentrySDK.close()
    }
}
