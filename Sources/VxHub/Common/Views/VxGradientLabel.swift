//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioğlu on 3.04.2025.
//

import Foundation
import UIKit

class VxGradientLabel: UILabel {
    private let gradientLayer = CAGradientLayer()
    private var gradientColors: [CGColor]
    
    init(gradientColors: [CGColor]) {
        self.gradientColors = gradientColors
        super.init(frame: .zero)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradient() {
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        
        // Only update if we have a valid size
        if !bounds.size.width.isZero && !bounds.size.height.isZero {
            updateGradientText()
        }
    }
    
    private func updateGradientText() {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        
        let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)
        let gradientImage = renderer.image { context in
            gradientLayer.render(in: context.cgContext)
        }
        
        // Apply the gradient image as the text color
        let gradientColor = UIColor(patternImage: gradientImage)
        self.textColor = gradientColor
    }
    
    func updateGradientColors(_ colors: [CGColor]) {
        gradientColors = colors
        gradientLayer.colors = colors
        if !bounds.size.width.isZero && !bounds.size.height.isZero {
            updateGradientText()
        }
    }
}
