//
//  VxFirebaseProviderImpl.swift
//  VxHub
//
//  Created by VxHub on 2025.
//

import Foundation
import VxHubCore
import FirebaseAnalytics
@_implementationOnly import FirebaseCore

public struct VxFirebaseProviderImpl: VxFirebaseProvider, Sendable {

    public init() {}

    // MARK: - VxFirebaseProvider

    public var appInstanceId: String {
        return Analytics.appInstanceID() ?? ""
    }

    public func configure(path: URL) {
        guard FirebaseApp.app() == nil else {
            VxLogger.shared.log("Firebase already configured, skipping", level: .info, type: .info)
            return
        }

        let filePath = path.path

        guard let options = FirebaseOptions(contentsOfFile: filePath) else {
            VxLogger.shared.log("Failed to load Firebase configuration from \(filePath)", level: .error, type: .error)
            return
        }
        FirebaseApp.configure(options: options)
    }
}
