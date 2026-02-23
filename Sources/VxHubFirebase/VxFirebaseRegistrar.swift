import Foundation
import VxHubCore

@objc(VxFirebaseRegistrar)
public final class VxFirebaseRegistrar: NSObject {
    @objc public static func register() {
        VxProviderRegistry.shared.firebaseProvider = VxFirebaseProviderImpl()
    }
}
