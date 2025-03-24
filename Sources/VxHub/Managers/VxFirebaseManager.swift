//
//  File.swift
//  VxHub
//
//  Created by furkan on 4.11.2024.
//

import Foundation
import FirebaseAnalytics
@_implementationOnly import FirebaseCore

struct VxFirebaseManager {
    public init() {}
    public var appInstanceId: String {
        return Analytics.appInstanceID() ?? ""
    }
    
    public func configure(path: URL) {
        guard let options = FirebaseOptions(contentsOfFile: path.path) else {
            VxLogger.shared.log("Failed to load Firebase configuration from \(path.path)", level: .error, type: .error)
            return
        }
        debugPrint("FirebaseApp configured successfully")
        FirebaseApp.configure(options: options)
    }
}
