#if canImport(UIKit)
import UIKit

public extension UIImageView {
    func vxSetImage(
        with url: URL?,
        activityIndicatorTintColor: UIColor = .gray,
        placeholderImage: UIImage? = nil,
        showLoadingIndicator: Bool = true,
        indicatorSize: Int = 4,
        completion: (@Sendable (UIImage?, Error?) -> Void)? = nil
    ) {
        guard let provider = VxProviderRegistry.shared.imageCachingProvider else {
            VxLogger.shared.warning("Image caching provider not registered, vxSetImage will not work")
            completion?(nil, nil)
            return
        }
        provider.setImage(
            on: self,
            with: url,
            activityIndicatorTintColor: activityIndicatorTintColor,
            placeholderImage: placeholderImage,
            showLoadingIndicator: showLoadingIndicator,
            indicatorSize: indicatorSize,
            completion: completion
        )
    }
}

extension UIImage {
    static func dynamicImage(light: UIImage?, dark: UIImage?) -> UIImage? {
        guard let lightImage = light, let darkImage = dark else {
            return light ?? dark
        }

        let imageAsset = UIImageAsset()
        imageAsset.register(lightImage, with: UITraitCollection(userInterfaceStyle: .light))
        imageAsset.register(darkImage, with: UITraitCollection(userInterfaceStyle: .dark))

        return imageAsset.image(with: UITraitCollection(userInterfaceStyle: .unspecified))
    }
}
#endif
