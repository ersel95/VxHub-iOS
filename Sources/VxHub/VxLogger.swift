//
//  VxLogger.swift
//  VxHub
//
//  Created by Mr. t. on 18.09.2024.
//

import os.log

internal final class VxLogger: @unchecked Sendable {

    private static let queue = DispatchQueue(label: "com.vxhub.queue")
    nonisolated(unsafe) private static var instance: VxLogger?
    
    static var shared: VxLogger {
        return queue.sync {
            if let instance = instance {
                return instance
            } else {
                instance = VxLogger()
                return instance!
            }
        }
    }
    private var logLevel: OSLogType = .debug
    private let logger = OSLog(subsystem: "com.example.abdul", category: "abdul networking")

    internal init(level: OSLogType? = nil) {
        if let level {
            self.logLevel = level
        }
        self.log(message: "Starting VxLogger with logLevel key: \(self.logLevel)")
    }
    
    internal func log(message: String) {
        os_log("%{public}@", log: self.logger, type: self.logLevel, message as! CVarArg)
    }
}
