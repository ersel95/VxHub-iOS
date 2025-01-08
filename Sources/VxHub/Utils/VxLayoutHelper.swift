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
    
    public init() {
        DispatchQueue.main.async { [weak self] in
            self?.window = UIApplication.shared.keyWindow
            self?.topPadding = self?.window?.safeAreaInsets.top ?? 0
            self?.bottomPadding = self?.window?.safeAreaInsets.bottom ?? 0
        }
    }
    
    public var safeAreaTopPadding: CGFloat {
        topPadding
    }
    
    public var safeAreaBottomPadding: CGFloat {
        bottomPadding
    }

}
