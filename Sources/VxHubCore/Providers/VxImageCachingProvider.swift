#if canImport(UIKit)
import UIKit

public protocol VxImageCachingProvider: Sendable {
    func setImage(
        on imageView: UIImageView,
        with url: URL?,
        activityIndicatorTintColor: UIColor,
        placeholderImage: UIImage?,
        showLoadingIndicator: Bool,
        indicatorSize: Int,
        completion: (@Sendable (UIImage?, Error?) -> Void)?
    )
}
#endif
