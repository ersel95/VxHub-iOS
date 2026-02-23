#if os(iOS)
import Foundation
import VxHubCore

@objc(VxFacebookRegistrar)
public final class VxFacebookRegistrar: NSObject {
    @objc public static func register() {
        VxProviderRegistry.shared.facebookProvider = VxFacebookProviderImpl()
    }
}
#endif
