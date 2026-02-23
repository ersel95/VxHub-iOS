import Foundation
import VxHubCore

@objc(VxRevenueCatRegistrar)
public final class VxRevenueCatRegistrar: NSObject {
    @objc public static func register() {
        VxProviderRegistry.shared.purchaseProvider = VxRevenueCatProvider()
    }
}
