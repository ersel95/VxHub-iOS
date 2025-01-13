//
//  File.swift
//  VxHub
//
//  Created by furkan on 6.11.2024.
//

import Foundation
import UIKit

public extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    class func colorConverter (_ hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let alpha, red, green, blue: CGFloat
        switch hexSanitized.count {
        case 8:
            alpha = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            red   = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            green = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            blue  = CGFloat(rgb & 0x000000FF) / 255.0

        case 6:
            alpha = 1.0
            red   = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            blue  = CGFloat(rgb & 0x0000FF) / 255.0

        default:
            alpha = 1.0
            red   = 1.0
            green = 1.0
            blue  = 1.0
        }

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    class func colorTransition(col1: UIColor, col2: UIColor, percent: CGFloat) -> UIColor { // MARK: Percent should be between 0-1
        let c1 = CIColor(color: col1)
        let c2 = CIColor(color: col2)
        let alpha = (c2.alpha - c1.alpha) * percent + c1.alpha
        let red = (c2.red - c1.red) * percent + c1.red
        let blue = (c2.blue - c1.blue) * percent + c1.blue
        let green = (c2.green - c1.green) * percent + c1.green
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIColor {
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}

