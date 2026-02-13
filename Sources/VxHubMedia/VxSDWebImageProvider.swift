#if canImport(UIKit)
//
//  VxSDWebImageProvider.swift
//  VxHub
//
//  Created by VxHub on 2025.
//

import UIKit
import VxHubCore
import SDWebImage

public final class VxSDWebImageProvider: VxImageCachingProvider, @unchecked Sendable {

    public init() {}

    // MARK: - VxImageCachingProvider

    public func setImage(
        on imageView: UIImageView,
        with url: URL?,
        activityIndicatorTintColor: UIColor,
        placeholderImage: UIImage?,
        showLoadingIndicator: Bool,
        indicatorSize: Int,
        completion: (@Sendable (UIImage?, Error?) -> Void)?
    ) {
        DispatchQueue.main.async {
            if showLoadingIndicator {
                let size = ActivityIndicatorType(rawValue: indicatorSize) ?? .medium
                let activityIndicator = size.sdActivityIndicator
                activityIndicator.indicatorView.tintColor = activityIndicatorTintColor
                imageView.sd_imageIndicator = activityIndicator
            } else {
                imageView.sd_imageIndicator = nil
            }

            guard let url = url else {
                completion?(nil, NSError(
                    domain: "VxSDWebImageProvider",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
                ))
                return
            }

            imageView.sd_setImage(with: url, placeholderImage: placeholderImage) { image, error, _, _ in
                completion?(image, error)
            }
        }
    }

    // MARK: - Activity Indicator Mapping

    private enum ActivityIndicatorType: Int {
        case gray = 0
        case grayLarge = 1
        case white = 2
        case whiteLarge = 3
        case medium = 4
        case large = 5

        var sdActivityIndicator: SDWebImageActivityIndicator {
            switch self {
            case .gray:
                return .gray
            case .grayLarge:
                return .grayLarge
            case .white:
                return .white
            case .whiteLarge:
                return .whiteLarge
            case .medium:
                return .medium
            case .large:
                return .large
            }
        }
    }
}
#endif
