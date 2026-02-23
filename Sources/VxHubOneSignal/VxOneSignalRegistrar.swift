#if os(iOS)
import Foundation
import VxHubCore

@objc(VxOneSignalRegistrar)
public final class VxOneSignalRegistrar: NSObject {
    @objc public static func register() {
        VxProviderRegistry.shared.pushProvider = VxOneSignalProvider()
    }
}
#endif
