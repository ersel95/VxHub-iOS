import Foundation

public protocol VxAnalyticsProvider: Sendable {
    func initialize(userId: String, apiKey: String, deploymentKey: String?, deviceId: String, isSubscriber: Bool)
    func logEvent(eventName: String, properties: [AnyHashable: Any]?)
    func getVariantType(for flagKey: String) -> String?
    func getPayload(for flagKey: String) -> [String: Any]?
    func changeVid(vid: String?)
    func setLoginDatas(_ fullName: String?, _ email: String?)
    var didStartExperiment: Bool { get }
}
