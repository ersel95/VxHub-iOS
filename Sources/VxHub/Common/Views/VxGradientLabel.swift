//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioğlu on 3.04.2025.
//

import Foundation
import UIKit

final class VxGradientLabel: UILabel {
    var gradientColors: [CGColor]

    init(gradientColors: [CGColor]) {
        self.gradientColors = gradientColors
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        self.gradientColors = [UIColor.black.cgColor]
        super.init(coder: coder)
    }

    // Override drawText to apply gradient
    override func drawText(in rect: CGRect) {
        if let gradientColor = drawGradientColor(in: rect, colors: gradientColors) {
            self.textColor = gradientColor
        }
        super.drawText(in: rect)
    }

    // Helper method to create gradient color
    private func drawGradientColor(in rect: CGRect, colors: [CGColor]) -> UIColor? {
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.saveGState()
        defer { currentContext?.restoreGState() }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil) else { return nil }

        let startPoint = CGPoint(x: rect.minX, y: rect.midY)
        let endPoint = CGPoint(x: rect.maxX, y: rect.midY)

        currentContext?.clip(to: rect)
        currentContext?.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)

        return nil
    }
}
