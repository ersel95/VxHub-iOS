import Foundation
import VxHubCore

@objc(VxAmplitudeRegistrar)
public final class VxAmplitudeRegistrar: NSObject {
    @objc public static func register() {
        VxProviderRegistry.shared.analyticsProvider = VxAmplitudeProvider()
    }
}
