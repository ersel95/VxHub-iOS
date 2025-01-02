//
//  File.swift
//  VxHub
//
//  Created by furkan on 4.11.2024.
//

import Foundation
import FirebaseAnalytics
@_implementationOnly import FirebaseCore

open class VxFirebaseManager: @unchecked Sendable {
    
    public static let shared = VxFirebaseManager()
    
    public var appInstanceId: String {
        return Analytics.appInstanceID() ?? ""
    }
    
    public func configure(path: URL) {
        guard let options = FirebaseOptions(contentsOfFile: path.path) else {
            VxLogger.shared.log("Failed to load Firebase configuration from \(path.path)", level: .error, type: .error)
            return
        }
        FirebaseApp.configure(options: options)
    }
}
