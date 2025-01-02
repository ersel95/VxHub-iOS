//
//  File.swift
//  VxHub
//
//  Created by furkan on 2.01.2025.
//

import UIKit
import SDWebImage

public extension UIImageView {
    func vxSetImage(
        with url: URL?,
        activityIndicatorTintColor: UIColor = .gray,
        placeholderImage: UIImage? = nil,
        showLoadingIndicator: Bool = true,
        indicatorSize: Int = 4, // Default to medium
        completion: (@Sendable (UIImage?, Error?) -> Void)? = nil
    ) {
        let imageManager = VxImageManager()
        imageManager.setImage(
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
