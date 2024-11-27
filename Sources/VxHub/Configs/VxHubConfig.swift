//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation

public struct VxHubConfig: @unchecked Sendable {
    public let hubId: String
    public let environment: VxHubEnvironment
    public let responseQueue: DispatchQueue
    public let requestAtt: Bool
    public var googlePlistFileName: String
    public var logLevel: LogLevel
    
    public init(hubId: String, environment: VxHubEnvironment = .prod, responseQueue: DispatchQueue = .main, requestAtt: Bool = false, googlePlistFileName: String = "GoogleService-Info", logLevel: LogLevel = .verbose) {
        self.hubId = hubId
        self.environment = environment
        self.responseQueue = responseQueue
        self.requestAtt = requestAtt
        self.googlePlistFileName = googlePlistFileName
        self.logLevel = logLevel
    }
    
    public init(hubId: String) {
        self.hubId = hubId
        self.environment = .prod
        self.responseQueue = .main
        self.requestAtt = true
        self.googlePlistFileName = "GoogleService-Info"
        self.logLevel = .debug
    }
}

public enum VxHubEnvironment: String { //TODO: MOVE ME
    case stage, prod
}
