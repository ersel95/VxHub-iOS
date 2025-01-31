//
//  File.swift
//  VxHub
//
//  Created by furkan on 16.01.2025.
//

import UIKit
import Combine

open class VxButton: UIButton {
    // MARK: - Properties
    private var disposeBag = Set<AnyCancellable>()
    private let textSubject = CurrentValueSubject<String?, Never>(nil)
    private var vxFont: VxPaywallFont?
    private var lastProcessedText: String?
    private var pendingText: String?
    private var pendingValues: [Any]?
    private var _font: UIFont?
    private var currentConfiguration: Configuration?
    private var savedAttributedTitle: AttributedString?
    private var savedTitle: String?
    
    // Add these properties here, at the top with other properties
    private var _currentImage: UIImage?
    private var _currentImagePadding: CGFloat?
    
    // MARK: - Public Properties
    public var isLoading: Bool = false {
        didSet {
            updateLoadingState()
        }
    }
    
    // MARK: - Initialization
    public init(frame: CGRect = .zero,
                font: VxPaywallFont? = nil,
                fontSize: CGFloat = 14,
                weight: VxFontWeight = .regular) {
        super.init(frame: frame)
        commonInit()
        if let font {
            self.setFont(font, size: fontSize, weight: weight)
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupBindings()
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
    // MARK: - Configuration
    public func configure(backgroundColor: UIColor,
                          foregroundColor: UIColor,
                          cornerRadius: CGFloat = 16,
                          imagePadding: CGFloat = 0,
                          contentInsets: NSDirectionalEdgeInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)) {
        self.clipsToBounds = true
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = backgroundColor
        configuration.baseForegroundColor = foregroundColor
        configuration.imagePadding = imagePadding
        configuration.contentInsets = contentInsets
        self.configuration = configuration
        self.layer.cornerRadius = cornerRadius
        self.currentConfiguration = configuration
    }
    
    public func setFont(_ font: VxPaywallFont, size: CGFloat, weight: VxFontWeight) {
        self.vxFont = font
        self._font = VxFontManager.shared.font(font: font, size: size, weight: weight)
        
        if let pendingText = pendingText {
            self.setTitle(pendingText, for: .normal)
            self.pendingText = nil
        }
    }
    
    // MARK: - Title Setting
    public override func setTitle(_ title: String?, for state: UIControl.State) {
        guard let title = title else { return }
        if title == lastProcessedText { return }
        if title.isEmpty { return }
        
        if vxFont == nil {
            pendingText = title
            return
        }
        
        let interpolatedText = title
        
        if let pendingValues = pendingValues {
            let processedText = applyValues(pendingValues, to: interpolatedText)
            self.pendingValues = nil
            
            if processedText.containsFormatting() {
                textSubject.send(processedText)
            } else {
                setDefaultTitle(processedText, for: state)
            }
        } else {
            if interpolatedText.containsFormatting() {
                textSubject.send(interpolatedText)
            } else {
                setDefaultTitle(interpolatedText, for: state)
            }
        }
        
        lastProcessedText = title
    }
    
    private func setDefaultTitle(_ title: String, for state: UIControl.State) {
        guard let font = _font else {
            super.setTitle(title, for: state)
            return
        }
        
        let attributedString = AttributedString(
            title,
            attributes: AttributeContainer([
                .font: font,
                .foregroundColor: configuration?.baseForegroundColor ?? .white
            ])
        )
        
        var config = configuration
        config?.attributedTitle = attributedString
        configuration = config
    }
    
    // MARK: - Loading State
    private func updateLoadingState() {
        var config = configuration
        config?.showsActivityIndicator = isLoading
        
        if isLoading {
            savedAttributedTitle = config?.attributedTitle
            savedTitle = config?.title
            config?.attributedTitle = AttributedString("")
        } else {
            if let savedAttributedTitle {
                config?.attributedTitle = savedAttributedTitle
                self.savedAttributedTitle = nil
            } else if let savedTitle {
                setTitle(savedTitle, for: .normal)
                self.savedTitle = nil
            }
        }
        
        configuration = config
        isEnabled = !isLoading
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        textSubject
            .receive(on: DispatchQueue.main)
            .compactMap { [weak self] text -> NSAttributedString? in
                guard let self = self,
                      let text = text,
                      let font = self._font else { return nil }
                
                if let pendingValues = pendingValues {
                    let processedText = applyValues(pendingValues, to: text)
                    self.pendingValues = nil
                    return self.processAttributedText(processedText,
                                                    font: font,
                                                    textColor: configuration?.baseForegroundColor ?? .white)
                } else {
                    return self.processAttributedText(text,
                                                    font: font,
                                                    textColor: configuration?.baseForegroundColor ?? .white)
                }
            }
            .sink { [weak self] attributedString in
                var config = self?.configuration
                config?.attributedTitle = AttributedString(attributedString)
                self?.configuration = config
            }
            .store(in: &disposeBag)
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
    
    public func setTitleWithImage(_ title: String?, image: UIImage, imagePadding: CGFloat = 8) {
        self._currentImage = image
        self._currentImagePadding = imagePadding
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        
        if let font = _font {
            let imageYOffset = (font.capHeight - image.size.height).rounded() / 2
            imageAttachment.bounds = CGRect(x: 0, y: imageYOffset, width: image.size.width, height: image.size.height)
        }
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        
        if let title = title {
            attributedString.append(NSAttributedString(string: "  " + title))
        }
        
        if let font = _font {
            attributedString.addAttribute(.font, 
                                       value: font, 
                                       range: NSRange(location: 0, length: attributedString.length))
        }
        
        let color = configuration?.baseForegroundColor ?? .white
        attributedString.addAttribute(.foregroundColor, 
                                    value: color, 
                                    range: NSRange(location: 0, length: attributedString.length))
        
        var config = configuration
        config?.attributedTitle = AttributedString(attributedString)
        configuration = config
    }
    
    public func setForegroundColor(_ color: UIColor) {
        var config = configuration
        config?.baseForegroundColor = color
        
        if let currentImage = _currentImage, 
           let title = configuration?.title {
            setTitleWithImage(title, image: currentImage, imagePadding: _currentImagePadding ?? 8)
        } else if let title = config?.attributedTitle {
            var attributedTitle = title
            attributedTitle.foregroundColor = color
            config?.attributedTitle = attributedTitle
        }
        
        configuration = config
    }
}

// MARK: - Public Extensions
public extension VxButton {
    func replaceValues(_ values: [Any]?) {
        guard let values = values else { return }
        
        if let currentTitle = self.configuration?.title {
            let newText = applyValues(values, to: currentTitle)
            self.setTitle(newText, for: .normal)
        } else {
            pendingValues = values
        }
    }
    
    private func applyValues(_ values: [Any], to text: String) -> String {
        return values.enumerated().reduce(text) { currentText, pair in
            let (index, value) = pair
            let key = "{{value_\(index + 1)}}"
            return currentText.replacingOccurrences(of: key, with: "\(value)")
        }
    }
}

public extension NSRegularExpression {
    func stringByReplacingMatches(
        in string: String,
        range: NSRange,
        withTemplate template: (String) -> String
    ) -> String {
        guard range.location != NSNotFound,
              range.length <= string.utf16.count,
              range.location + range.length <= string.utf16.count else {
            return string
        }
        
        let matches = matches(in: string, options: [], range: range)
        var result = string
        
        for match in matches.reversed() {
            let matchRange = match.range
            guard matchRange.location != NSNotFound,
                  matchRange.length <= result.utf16.count,
                  matchRange.location + matchRange.length <= result.utf16.count else {
                continue
            }
            
            let nsString = result as NSString
            let matchText = nsString.substring(with: matchRange)
            let replacement = template(matchText)
            result = nsString.replacingCharacters(in: matchRange, with: replacement)
        }
        
        return result
    }
}

