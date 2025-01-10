//
//  File.swift
//  VxHub
//
//  Created by furkan on 8.01.2025.
//

import UIKit

final class VxLayoutHelper: @unchecked Sendable {
    
    private var window: UIWindow?
    private var topPadding: CGFloat = 0
    private var bottomPadding: CGFloat = 0
    
    // Reference device dimensions (iPhone X)
    private let referenceWidth: CGFloat = 375
    private let referenceHeight: CGFloat = 812
    
    // Current device dimensions
    private var deviceWidth: CGFloat = 0
    private var deviceHeight: CGFloat = 0
    
    public init() {}
    
    public func initalizeLayoutHelper(completion: @escaping @Sendable () -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.window = UIApplication.shared.keyWindow
            self?.topPadding = self?.window?.safeAreaInsets.top ?? 0
            self?.bottomPadding = self?.window?.safeAreaInsets.bottom ?? 0
            self?.deviceWidth = UIScreen.main.bounds.width
            self?.deviceHeight = UIScreen.main.bounds.height
            completion()
        }
    }
    
    public var safeAreaTopPadding: CGFloat {
        return topPadding
    }
    
    public var safeAreaBottomPadding: CGFloat {

        return bottomPadding
    }
    
    public func adaptiveHeight(_ value: CGFloat) -> CGFloat {
        let scaleFactor = deviceHeight / referenceHeight
        let scaledValue = value * scaleFactor
        
        // iPhone SE (1st and 2nd gen) and mini devices have height <= 667
        let isCompactDevice = deviceHeight <= 667
        // Pro Max devices have height >= 926
        let isLargeDevice = deviceHeight >= 926
        
        if isCompactDevice {
            return scaledValue * 0.75 // Reduce by 25% for SE/mini
        } else if isLargeDevice {
            return scaledValue * 1.25 // Increase by 25% for Pro Max
        }
        
        return scaledValue
    }

    public func adaptiveWidth(_ value: CGFloat) -> CGFloat {
        let scaleFactor = deviceWidth / referenceWidth
        return value * scaleFactor
    }

    public func adaptiveDimension(_ value: CGFloat) -> CGFloat {
        let scaleFactor = min(deviceWidth / referenceWidth, deviceHeight / referenceHeight)
        return value * scaleFactor
    }
}
