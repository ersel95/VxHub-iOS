//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 17.01.2025.
//

import Foundation
import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
private typealias PlatformFont = UIFont
private typealias PlatformColor = UIColor
#elseif os(macOS)
import AppKit
private typealias PlatformFont = NSFont
private typealias PlatformColor = NSColor
#endif

#if os(macOS)
private extension NSColor {
    var hexString: String {
        guard let color = usingColorSpace(.sRGB) else { return "#000000" }
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}
#endif

public struct VxButtonView: View {
    // MARK: - Properties
    private let title: String
    private let vxFont: VxFont?
    private let fontSize: CGFloat
    private let weight: VxFontWeight
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let cornerRadius: CGFloat
    private let frameAlignment: Alignment
    private let action: () -> Void
    @State private var attributedText: AttributedString?
    @State private var localizedText: String?
    @State private var isLoading = false
    
    // MARK: - Initialization
    public init(
        title: String,
        font: VxFont? = nil,
        fontSize: CGFloat = 14,
        weight: VxFontWeight = .regular,
        backgroundColor: Color,
        foregroundColor: Color,
        cornerRadius: CGFloat = 16,
        action: @escaping () -> Void,
        frameAlignment: Alignment = .center
    ) {
        self.title = title
        self.vxFont = font
        self.fontSize = fontSize
        self.weight = weight
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.action = action
        self.frameAlignment = frameAlignment
    }
    
    // MARK: - Body
    public var body: some View {
        Button(action: {
            if !isLoading {
                action()
            }
        }) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                } else {
                    if let attributedText {
                        Text(attributedText)
                            .frame(alignment: frameAlignment)
                    } else {
                        Text(localizedText ?? title)
                            .frame(alignment: frameAlignment)
                            .font(vxFont.map { font in
                                let uiFont = VxFontManager.shared.font(font: font, size: fontSize, weight: weight)
                                return Font(uiFont as CTFont)
                            } ?? .system(size: fontSize))
                         .foregroundColor(foregroundColor)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(cornerRadius)
        }
        .disabled(isLoading)
        .onAppear {
            processText()
        }
    }
    
    // MARK: - Private Methods
    private func processText() {
        let interpolatedText = title
        if interpolatedText.containsFormatting() {
            let platformFont: PlatformFont = vxFont.map { VxFontManager.shared.font(font: $0, size: fontSize, weight: weight) }
                ?? PlatformFont.systemFont(ofSize: fontSize)
            let platformColor = PlatformColor(foregroundColor)

            if let processed = processAttributedText(interpolatedText, font: platformFont, textColor: platformColor) {
                attributedText = AttributedString(processed)
            }
        } else {
            localizedText = interpolatedText
        }
    }

    private func processAttributedText(_ text: String, font: PlatformFont, textColor: PlatformColor) -> NSAttributedString? {
        var htmlString = text
        
        let rgbPattern = "\\[color=rgb\\((\\d+),\\s*(\\d+),\\s*(\\d+)\\)\\]"
        if let regex = try? NSRegularExpression(pattern: rgbPattern, options: .caseInsensitive) {
            let range = NSRange(location: 0, length: text.utf8.count)
            htmlString = regex.stringByReplacingMatches(in: text, range: range) { match in
                let components = match.matches(pattern: "(\\d+)")
                guard components.count >= 3,
                      let r = Int(components[0]),
                      let g = Int(components[1]),
                      let b = Int(components[2]) else {
                    return "<font>"
                }
                return String(format: "<font color=\"#%02X%02X%02X\">", r, g, b)
            }
        }
        
        htmlString = htmlString
            .replacingOccurrences(of: "\\[color=#([A-Fa-f0-9]{6})\\]", with: "<font color=\"#$1\">", options: .regularExpression)
            .replacingOccurrences(of: "\\[/color\\]", with: "</font>", options: .regularExpression)
            .replacingOccurrences(of: "[b]", with: "<strong>")
            .replacingOccurrences(of: "[/b]", with: "</strong>")
        
        htmlString = "<span style=\"color: \(textColor.hexString)\">\(htmlString)</span>"
        
        guard let data = htmlString.data(using: .utf8) else { return nil }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            let mutableString = NSMutableAttributedString(attributedString: attributedString)
            
            mutableString.addAttribute(.font, value: font, range: NSRange(location: 0, length: mutableString.length))
            
            let boldPattern = "<strong>(.*?)</strong>"
            if let regex = try? NSRegularExpression(pattern: boldPattern, options: [.dotMatchesLineSeparators]) {
                let matches = regex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.count))
                for match in matches {
                    if match.numberOfRanges >= 2 {
                        let boldTextRange = match.range(at: 1)
                        if let boldTextRange = Range(boldTextRange, in: htmlString) {
                            let boldText = String(htmlString[boldTextRange])
                            if let range = mutableString.string.range(of: boldText) {
                                let nsRange = NSRange(range, in: mutableString.string)
                                if let vxFont = vxFont {
                                    let boldFont = VxFontManager.shared.font(font: vxFont, 
                                                                          size: font.pointSize,
                                                                          weight: .bold)
                                    mutableString.addAttribute(.font, value: boldFont, range: nsRange)
                                }
                            }
                        }
                    }
                }
            }
            
            return mutableString
        } catch {
            debugPrint("Error converting BBCode to attributed string: \(error)")
            return nil
        }
    }
    
}
