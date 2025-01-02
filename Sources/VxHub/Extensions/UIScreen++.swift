//
//  File.swift
//  VxHub
//
//  Created by furkan on 2.01.2025.
//

import UIKit

extension UIScreen {
    public var resolution: String {
        let width = Int(bounds.width * scale)
        let height = Int(bounds.height * scale)
        return "\(width)x\(height)"
    }
}

