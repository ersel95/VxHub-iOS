//
//  File.swift
//  VxHub
//
//  Created by furkan on 7.11.2024.
//

import Foundation

public enum LogLevel: Int, Comparable {
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
    case networkRequest = "🌐 REQUEST"
    case networkResponse = "📩 RESPONSE"
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
    
    internal func setLogLevel(_ level: LogLevel) {
        minimumLogLevel = level
    }
    
    internal func log(_ message: String, level: LogLevel, type: LogType = .info) {
        guard level >= minimumLogLevel else { return }
        
        let timestamp = dateFormatter.string(from: Date())
        let formattedMessage = "VXHUB: [\(timestamp)] \(type.rawValue): \(message)"
        
        #if DEBUG
        debugPrint(formattedMessage)
        #endif
    }
    
    internal func verbose(_ message: String) {
        log(message, level: .verbose, type: .info)
    }
    
    internal func debug(_ message: String) {
        log(message, level: .debug, type: .info)
    }
    
    internal func info(_ message: String) {
        log(message, level: .info, type: .info)
    }
    
    internal func warning(_ message: String) {
        log(message, level: .warning, type: .warning)
    }
    
    internal func error(_ message: String) {
        log(message, level: .error, type: .error)
    }
    
    internal func success(_ message: String) {
        log(message, level: .info, type: .success)
    }
    
    internal func logRequest(request: URLRequest) {
        guard minimumLogLevel <= .debug else { return }
        print("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)
        
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"
        
        var logOutput = """
                        \(urlAsString) \n\n
                        \(method) \(path)?\(query) HTTP/1.1 \n
                        HOST: \(host)\n
                        """
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            logOutput += "\(key): \(value) \n"
        }
        if let body = request.httpBody {
            logOutput += "\n \(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
        }
        
        print(logOutput)
    }
}
