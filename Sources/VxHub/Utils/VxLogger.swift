//
//  File.swift
//  VxHub
//
//  Created by furkan on 7.11.2024.
//

import Foundation

internal enum LogLevel: Int, Comparable {
    case verbose = 0, debug, info, warning, error
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

internal enum LogType: String {
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
    case success = "✅ SUCCESS"
}

internal final class VxLogger: @unchecked Sendable {
    
    internal static let shared = VxLogger()
    
    private var minimumLogLevel: LogLevel = .info
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    private init() {}
    
    public func setLogLevel(_ level: LogLevel) {
        minimumLogLevel = level
    }
    
    public func log(_ message: String, level: LogLevel, type: LogType = .info) {
        guard level >= minimumLogLevel else { return }
        
        let timestamp = dateFormatter.string(from: Date())
        let formattedMessage = "VXHUB: [\(timestamp)] \(type.rawValue): \(message)"
        
        #if DEBUG
        debugPrint(formattedMessage)
        #else
        NSLog("%@", formattedMessage)
        #endif
    }
    
    public func verbose(_ message: String) {
        log(message, level: .verbose, type: .info)
    }
    
    public func debug(_ message: String) {
        log(message, level: .debug, type: .info)
    }
    
    public func info(_ message: String) {
        log(message, level: .info, type: .info)
    }
    
    public func warning(_ message: String) {
        log(message, level: .warning, type: .warning)
    }
    
    public func error(_ message: String) {
        log(message, level: .error, type: .error)
    }
    
    public func success(_ message: String) {
        log(message, level: .info, type: .success)
    }
}
