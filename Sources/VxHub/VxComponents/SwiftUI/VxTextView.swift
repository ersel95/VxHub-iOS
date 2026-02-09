//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 17.01.2025.
//

import Foundation
import SwiftUI
import Combine
import CoreText
#if canImport(UIKit)
import UIKit
private typealias PlatformFont = UIFont
private typealias PlatformColor = UIColor
#elseif os(macOS)
import AppKit
private typealias PlatformFont = NSFont
private typealias PlatformColor = NSColor

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

public struct VxTextView: View {
    // MARK: - Properties
    private let text: String
    private let vxFont: VxFont?
    private let fontSize: CGFloat
    private let weight: VxFontWeight
    private let textColor: Color
    @State private var attributedText: AttributedString?
    @State private var localizedText: String?
    @State private var linkRanges: [(url: String, range: NSRange)] = []
    
    // MARK: - Initialization
    public init(
        text: String,
        font: VxFont? = nil,
        fontSize: CGFloat = 14,
        weight: VxFontWeight = .regular,
        textColor: Color = .primary
    ) {
        self.text = text
        self.vxFont = font
        self.fontSize = fontSize
        self.weight = weight
        self.textColor = textColor
    }
    
    // MARK: - Body
    public var body: some View {
        Group {
            if let attributedText {
                Text(attributedText)
                    .environment(\.openURL, OpenURLAction { url in
                        #if canImport(UIKit)
                        VxWebViewer.shared.present(url: url,
                                                 isFullscreen: false,
                                                 showCloseButton: false)
                        #elseif os(macOS)
                        NSWorkspace.shared.open(url)
                        #endif
                        return .handled
                    })
            } else {
                Text(localizedText ?? text)
                    .font(vxFont.map { font in
                        let uiFont = VxFontManager.shared.font(font: font, size: fontSize, weight: weight)
                        return Font(uiFont as CTFont)
                    } ?? .system(size: fontSize))
                    .foregroundColor(textColor)
            }
        }
        .onAppear {
            processText()
        }
    }
    
    // MARK: - Private Methods
    private func processText() {
        let interpolatedText = text
        if interpolatedText.containsFormatting() {
            let platformFont: PlatformFont = vxFont.map { VxFontManager.shared.font(font: $0, size: fontSize, weight: weight) }
            ?? PlatformFont.systemFont(ofSize: fontSize)

            if let processed = processAttributedText(interpolatedText, font: platformFont, textColor: PlatformColor(textColor)) {
                attributedText = AttributedString(processed)
            }
        } else {
            localizedText = interpolatedText
        }
    }
    
    private func boldForFont(_ baseFont: PlatformFont) -> PlatformFont {
        guard let vxFont = vxFont else {
            return PlatformFont.systemFont(ofSize: baseFont.pointSize, weight: .bold)
        }

        return VxFontManager.shared.font(font: vxFont, size: baseFont.pointSize, weight: .bold)
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
            .replacingOccurrences(of: "\\[url=([^\\]]+)\\]([^\\[]+)\\[/url\\]", with: "<a href=\"$1\">$2</a>", options: .regularExpression)
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
                                mutableString.addAttribute(.font, value: boldForFont(font), range: nsRange)
                            }
                        }
                    }
                }
            }
            
            linkRanges.removeAll()
            let urlPattern = "\\[url=([^\\]]+)\\]([^\\[]+)\\[/url\\]"
            let matches = text.matches(pattern: urlPattern)
            
            for i in stride(from: 0, to: matches.count - 1, by: 2) {
                guard i + 1 < matches.count else { break }
                let url = matches[i]
                let text = matches[i + 1]
                
                if let range = mutableString.string.range(of: text) {
                    let nsRange = NSRange(range, in: mutableString.string)
                    mutableString.addAttribute(.link, value: url, range: nsRange)
                    mutableString.addAttribute(.foregroundColor, value: PlatformColor.systemBlue, range: nsRange)
                    mutableString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
                    linkRanges.append((url: url, range: nsRange))
                }
            }
            
            return mutableString
        } catch {
            debugPrint("Error converting BBCode to attributed string: \(error)")
            return nil
        }
    }
}
