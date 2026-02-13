#if os(iOS)
import Foundation
import UIKit

public protocol VxPushProvider: Sendable {
    func initialize(appId: String, launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    func changeVid(for vid: String)
    func addEmail(_ email: String)
    func login(_ externalId: String)
    func logout()
    var playerId: String? { get }
    var playerToken: String? { get }
}
#endif
