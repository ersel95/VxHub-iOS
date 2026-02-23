import Foundation
import VxHubCore

@objc(VxSentryRegistrar)
public final class VxSentryRegistrar: NSObject {
    @objc public static func register() {
        VxProviderRegistry.shared.crashReportingProvider = VxSentryProviderImpl()
    }
}
