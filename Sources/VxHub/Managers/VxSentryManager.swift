//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 6.01.2025.
//

import Sentry

public struct VxSentryConfig {
    let environment: String
    let enableDebug: Bool
    let tracesSampleRate: Double
    let profilesSampleRate: Double
    let attachScreenshot: Bool
    let attachViewHierarchy: Bool
    
    public init(
        environment: VxHubEnvironment,
        enableDebug: Bool = false,
        tracesSampleRate: Double = 1.0,
        profilesSampleRate: Double = 1.0,
        attachScreenshot: Bool = false,
        attachViewHierarchy: Bool = false
    ) {
        if environment == .stage {
            self.environment =  "Debug"
        }else {
            self.environment =  "Release"
        }
        self.enableDebug = enableDebug
        self.tracesSampleRate = tracesSampleRate
        self.profilesSampleRate = profilesSampleRate
        self.attachScreenshot = attachScreenshot
        self.attachViewHierarchy = attachViewHierarchy
    }
}

internal struct VxSentryManager {
    private let defaultConfig = VxSentryConfig(
        environment: VxHub.shared.config?.environment ?? .stage,
        enableDebug: VxHub.shared.config?.environment == .stage ? true : false,
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
                options.attachScreenshot = sentryConfig.attachScreenshot
                options.attachViewHierarchy = sentryConfig.attachViewHierarchy
            }
            let user = User()
            user.userId = VxHub.shared.deviceId
            SentrySDK.setUser(user)
        }
}
