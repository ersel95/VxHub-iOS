import Foundation

public struct VxSentryConfig: Sendable {
    public let environment: String
    public let enableDebug: Bool
    public let tracesSampleRate: Double
    public let profilesSampleRate: Double
    public let attachScreenshot: Bool
    public let attachViewHierarchy: Bool

    public init(
        environment: VxHubEnvironment,
        enableDebug: Bool = false,
        tracesSampleRate: Double = 1.0,
        profilesSampleRate: Double = 1.0,
        attachScreenshot: Bool = false,
        attachViewHierarchy: Bool = false
    ) {
        if environment == .stage {
            self.environment = "Debug"
        } else {
            self.environment = "Release"
        }
        self.enableDebug = enableDebug
        self.tracesSampleRate = tracesSampleRate
        self.profilesSampleRate = profilesSampleRate
        self.attachScreenshot = attachScreenshot
        self.attachViewHierarchy = attachViewHierarchy
    }
}

public protocol VxCrashReportingProvider: Sendable {
    func start(dsn: String, environment: String, enableDebug: Bool, tracesSampleRate: Double, profilesSampleRate: Double, attachScreenshot: Bool, attachViewHierarchy: Bool)
    func stop()
    func setUserId(_ userId: String)
}
