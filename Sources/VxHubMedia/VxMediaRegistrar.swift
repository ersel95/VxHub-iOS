#if canImport(UIKit)
import Foundation
import VxHubCore

@objc(VxMediaRegistrar)
public final class VxMediaRegistrar: NSObject {
    @objc public static func register() {
        VxProviderRegistry.shared.imageCachingProvider = VxSDWebImageProvider()
        VxProviderRegistry.shared.animationProvider = VxLottieProviderImpl()
    }
}
#endif
