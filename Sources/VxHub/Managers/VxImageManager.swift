//
//  File.swift
//  VxHub
//
//  Created by furkan on 2.01.2025.
//

import Foundation
import SDWebImage
import UIKit

final internal class VxImageManager: @unchecked Sendable {
    /// Initializes the manager
    public init() {}
    
    /// Sets an image on a UIImageView with additional custom logic.
    /// - Parameters:
    ///   - imageView: The target UIImageView.
    ///   - url: The URL of the image.
    ///   - activityIndicatorTintColor: The tint color for the activity indicator.
    ///   - showLoading: Whether to show a loading indicator on the image view while loading.
    ///   - completion: An optional completion handler called after the image has been set.
    internal func setImage(
        on imageView: UIImageView,
        with url: URL?,
        activityIndicatorTintColor: UIColor,
        placeholderImage: UIImage?,
        showLoadingIndicator: Bool = false,
        indicatorSize: Int = 4, // Default to medium
        completion: (@Sendable (UIImage?, Error?) -> Void)? = nil
    ) {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            
            if showLoadingIndicator {
                let size = ActivityIndicatorType(rawValue: indicatorSize) ?? .medium
                let activityIndicator = size.sdActivityIndicator
                activityIndicator.indicatorView.tintColor = activityIndicatorTintColor
                imageView.sd_imageIndicator = activityIndicator
            } else {
                imageView.sd_imageIndicator = nil
            }
            
            guard let url = url else {
                completion?(nil, NSError(domain: "VxImageManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return
            }
            
            imageView.sd_setImage(with: url, placeholderImage: placeholderImage) { image, error, _, _ in
                completion?(image, error)
            }
        }
    }
    
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
