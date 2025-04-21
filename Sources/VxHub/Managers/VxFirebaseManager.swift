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
        let filePath = path.path
        
        guard let options = FirebaseOptions(contentsOfFile: filePath) else {
            VxLogger.shared.log("Failed to load Firebase configuration from \(filePath)", level: .error, type: .error)
            return
        }
        FirebaseApp.configure(options: options)
    }
}
