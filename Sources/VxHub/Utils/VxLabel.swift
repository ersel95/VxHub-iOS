import UIKit
import Combine

public final class VxLabel: UILabel {
    
    // MARK: - Properties
    private var disposeBag = Set<AnyCancellable>()
    private let textSubject = CurrentValueSubject<String?, Never>(nil)
    
    private var linkRanges: [(url: String, range: NSRange)] = []
    private var vxFont: VxPaywallFont = .rounded
    
    // MARK: - Font Override
    private var _font: UIFont?
    
    // MARK: - Initialization
    public init(frame: CGRect = .zero, font: VxPaywallFont? = nil, fontSize: CGFloat = 14, weight: VxFontWeight = .regular) {
        super.init(frame: frame)
        commonInit()
        if let font {
            self.setFont(font, size: fontSize, weight: weight)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func setFont(_ font: VxPaywallFont, size: CGFloat, weight: VxFontWeight) {
        self.vxFont = font
        self.font = VxFontManager.shared.font(font: font, size: size, weight: weight)
    }
    
    private var boldForFont: UIFont {
        switch vxFont {
        case .system(let string):
            return VxFontManager.shared.font(font: .system(string), size: font?.pointSize ?? 14, weight: .bold)
        case .custom(let string):
            return VxFontManager.shared.font(font: .custom(string), size: font?.pointSize ?? 14, weight: .bold)
        case .rounded:
            return VxFontManager.shared.font(font: .rounded, size: font?.pointSize ?? 14, weight: .bold)
        }
    }
    
    private func commonInit() {
        isUserInteractionEnabled = true
        numberOfLines = 0
        textAlignment = .center
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    public func localize(_ text: String, values: [Any]? = nil) {
        var interpolatedText = text
        
        if let values = values {
            let valueDict = values.enumerated().reduce(into: [String: String]()) { dict, pair in
                dict["value_\(pair.offset + 1)"] = "\(pair.element)"
            }
            
            for (key, value) in valueDict {
                interpolatedText = interpolatedText.replacingOccurrences(of: "{{\(key)}}", with: value)
            }
        }
        
        textSubject.send(interpolatedText)
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        textSubject
            .receive(on: DispatchQueue.main)
            .compactMap { [weak self] text -> NSAttributedString? in
                guard let self = self,
                      let text = text else { return nil }
                return self.processAttributedText(text, font: self.font!, textColor: self.textColor)
            }
            .sink { [weak self] attributedString in
                self?.attributedText = attributedString
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
                                mutableString.addAttribute(.font, value: boldForFont, range: nsRange)
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
                    mutableString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: nsRange)
                    mutableString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
                    linkRanges.append((url: url, range: nsRange))
                }
            }
            
            return mutableString
        } catch {
            return nil
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        let textContainer = NSTextContainer(size: bounds.size)
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: attributedText ?? NSAttributedString())
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (bounds.width - textBoundingBox.width) / 2 - textBoundingBox.minX,
            y: (bounds.height - textBoundingBox.height) / 2 - textBoundingBox.minY
        )
        
        let locationOfTouchInTextContainer = CGPoint(
            x: point.x - textContainerOffset.x,
            y: point.y - textContainerOffset.y
        )
        
        let indexOfCharacter = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        for (url, range) in linkRanges where NSLocationInRange(indexOfCharacter, range) {
            handleURL(url)
            break
        }
    }
    
    private func handleURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Helper Extensions
private extension NSRegularExpression {
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
