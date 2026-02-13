#if os(iOS)
import UIKit

public protocol VxFacebookProvider: Sendable {
    func initSdk(appId: String, clientToken: String, appName: String?)
    func setupFacebook(application: UIApplication, didFinishLaunching: [UIApplication.LaunchOptionsKey: Any]?)
    func setAttFlag()
    func openFacebookUrl(_ url: URL, application: UIApplication)
    var anonymousId: String { get }
}
#endif
