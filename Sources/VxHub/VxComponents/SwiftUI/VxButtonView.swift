//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 17.01.2025.
//

import Foundation
import SwiftUI
import Combine

public struct VxButtonView: View {
    // MARK: - Properties
    private let title: String
    private let font: VxPaywallFont?
    private let fontSize: CGFloat
    private let weight: VxFontWeight
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let cornerRadius: CGFloat
    private let action: () -> Void
    @State private var attributedText: AttributedString?
    @State private var isLoading = false
    
    // MARK: - Initialization
    public init(
        title: String,
        font: VxPaywallFont? = nil,
        fontSize: CGFloat = 14,
        weight: VxFontWeight = .regular,
        backgroundColor: Color,
        foregroundColor: Color,
        cornerRadius: CGFloat = 16,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.font = font
        self.fontSize = fontSize
        self.weight = weight
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.action = action
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
                    } else {
                        Text(title)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
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
        let uiFont = font.map { VxFontManager.shared.font(font: $0, size: fontSize, weight: weight) }
            ?? .systemFont(ofSize: fontSize)
        
        if let processed = processAttributedText(title, font: uiFont, textColor: UIColor(foregroundColor)) {
            attributedText = AttributedString(processed)
        }
    }

        private func processAttributedText(_ text: String, font: UIFont, textColor: UIColor) -> NSAttributedString? {
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
//                                if let vxFont = vxFont {
//                                    let boldFont = VxFontManager.shared.font(font: vxFont,
//                                                                          size: font.pointSize,
//                                                                          weight: .bold)
//                                    mutableString.addAttribute(.font, value: boldFont, range: nsRange)
//                                }
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
