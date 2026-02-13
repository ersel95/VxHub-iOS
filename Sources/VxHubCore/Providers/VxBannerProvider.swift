#if os(iOS)
import UIKit

public protocol VxBannerProvider: Sendable {
    func showBanner(_ message: String, type: VxBannerTypes, font: VxFont, buttonLabel: String?, action: (@Sendable () -> Void)?)
    func dismissCurrentBanner()
    func dismissAllBanners()
}
#endif
