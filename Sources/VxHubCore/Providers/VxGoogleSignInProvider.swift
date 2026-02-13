#if canImport(UIKit)
import UIKit

public protocol VxGoogleSignInProvider: Sendable {
    func signIn(
        clientID: String,
        presenting viewController: UIViewController,
        completion: @escaping @Sendable (_ userID: String?, _ idToken: String?, _ name: String?, _ email: String?, _ error: Error?) -> Void
    )
}
#endif
