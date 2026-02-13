import Foundation

public protocol VxAttributionDelegate: Sendable, AnyObject {
    func onConversionDataSuccess(_ info: [AnyHashable: Any])
    func onConversionDataFail(_ error: any Error)
}

public protocol VxAttributionProvider: Sendable {
    func initialize(
        devKey: String,
        appID: String,
        delegate: any VxAttributionDelegate,
        customerUserID: String,
        currentDeviceLanguage: String
    )
    func start()
    func logEvent(eventName: String, values: [String: Any]?)
    func changeVid(customerUserID: String)
    var attributionUID: String { get }
}
