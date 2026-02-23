#if os(iOS)
import Foundation
import VxHubCore

@objc(VxBannerRegistrar)
public final class VxBannerRegistrar: NSObject {
    @objc public static func register() {
        VxProviderRegistry.shared.bannerProvider = VxBannerProviderImpl()
    }
}
#endif
