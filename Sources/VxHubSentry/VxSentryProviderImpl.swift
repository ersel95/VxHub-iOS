//
//  VxSentryProviderImpl.swift
//  VxHub
//
//  Created by VxHub on 2025.
//

import Foundation
import VxHubCore
import Sentry

public struct VxSentryProviderImpl: VxCrashReportingProvider, Sendable {

    public init() {}

    // MARK: - VxCrashReportingProvider

    public func start(
        dsn: String,
        environment: String,
        enableDebug: Bool,
        tracesSampleRate: Double,
        profilesSampleRate: Double,
        attachScreenshot: Bool,
        attachViewHierarchy: Bool
    ) {
        SentrySDK.start { options in
            options.dsn = dsn
            options.debug = enableDebug
            options.environment = environment
            options.tracesSampleRate = NSNumber(value: tracesSampleRate)
            options.profilesSampleRate = NSNumber(value: profilesSampleRate)
            #if canImport(UIKit)
            options.attachScreenshot = attachScreenshot
            options.attachViewHierarchy = attachViewHierarchy
            #endif
        }
    }

    public func stop() {
        SentrySDK.close()
    }

    public func setUserId(_ userId: String) {
        let user = User()
        user.userId = userId
        SentrySDK.setUser(user)
    }
}
