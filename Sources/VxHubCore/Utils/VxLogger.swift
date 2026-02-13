//
//  File.swift
//  VxHub
//
//  Created by furkan on 7.11.2024.
//

import Foundation

public enum LogLevel: Int, Comparable, Sendable {
    case verbose = 0, debug, info, warning, error

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public enum LogType: String, Sendable {
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
    case success = "✅ SUCCESS"
    case networkRequest = "🌐 REQUEST"
    case networkResponse = "📩 RESPONSE"
}

public final class VxLogger: @unchecked Sendable {

    public static let shared = VxLogger()

    private var minimumLogLevel: LogLevel = .info
    private let logQueue = DispatchQueue(label: "com.vxhub.logger", qos: .utility)

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    private init() {}

    public func setLogLevel(_ level: LogLevel) {
        logQueue.sync { minimumLogLevel = level }
    }

    public func log(_ message: String, level: LogLevel, type: LogType = .info) {
        logQueue.async { [self] in
            guard level >= minimumLogLevel else { return }

            let timestamp = dateFormatter.string(from: Date())
            let formattedMessage = "VXHUB: [\(timestamp)] \(type.rawValue): \(message)"

            #if DEBUG
            debugPrint(formattedMessage)
            #endif
        }
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

    public func logRequest(request: URLRequest) {
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
