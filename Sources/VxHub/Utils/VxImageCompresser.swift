//
//  VxImageCompresser.swift
//  VxHub
//
//  Created by Furkan Alioglu on 6.01.2025.
//

import UIKit

internal struct VxImageCompresser {
    
    // Configuration
    private var maxDimension: CGFloat
    private let defaultCompressionQuality: CGFloat = 0.7
    
    public init(maxDimension: CGFloat = 2048) {
        self.maxDimension = maxDimension
    }
    
    /// Compresses image by resizing (if needed) and reducing quality
    /// - Parameters:
    ///   - image: Original UIImage
    ///   - maxSize: Maximum file size in bytes (default: 1MB)
    ///   - quality: Initial compression quality (0.0 to 1.0)
    /// - Returns: Compressed UIImage
    public func compressImage(
        _ image: UIImage,
        maxSize: Int = 1024 * 1024, // 1MB
        quality: CGFloat = 0.7
    ) -> UIImage {
        // First resize if needed
        let resizedImage = resizeImageIfNeeded(image)
        
        // Start with initial quality
        var compression = quality
        var data = resizedImage.jpegData(compressionQuality: compression)
        
        // Gradually decrease quality until we get under maxSize
        while data?.count ?? 0 > maxSize && compression > 0.1 {
            compression -= 0.1
            data = resizedImage.jpegData(compressionQuality: compression)
        }
        
        if let data = data, let compressedImage = UIImage(data: data) {
            return compressedImage
        }
        
        return resizedImage
    }
    
    private func resizeImageIfNeeded(_ image: UIImage) -> UIImage {
        let size = image.size
        
        // Check if resizing is needed
        guard size.width > maxDimension || size.height > maxDimension else {
            return image
        }
        
        // Calculate aspect ratio
        let widthRatio = maxDimension / size.width
        let heightRatio = maxDimension / size.height
        let scale = min(widthRatio, heightRatio)
        
        let newSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )
        
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
