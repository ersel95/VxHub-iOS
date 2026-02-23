#if canImport(UIKit)
import Foundation
import VxHubCore

@objc(VxGoogleSignInRegistrar)
public final class VxGoogleSignInRegistrar: NSObject {
    @objc public static func register() {
        VxProviderRegistry.shared.googleSignInProvider = VxGoogleSignInProviderImpl()
    }
}
#endif
