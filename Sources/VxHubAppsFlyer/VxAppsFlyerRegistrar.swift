#if os(iOS)
import Foundation
import VxHubCore

@objc(VxAppsFlyerRegistrar)
public final class VxAppsFlyerRegistrar: NSObject {
    @objc public static func register() {
        VxProviderRegistry.shared.attributionProvider = VxAppsFlyerProvider()
    }
}
#endif
