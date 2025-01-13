import UIKit
import Combine

public final class VxLabel: UILabel {
    
    // MARK: - Properties
    private var disposeBag = Set<AnyCancellable>()
    private let textSubject = CurrentValueSubject<String?, Never>(nil)
    private let fontSubject = CurrentValueSubject<UIFont?, Never>(nil)
    private let textColorSubject = CurrentValueSubject<UIColor?, Never>(nil)
    
    private var linkRanges: [(url: String, range: NSRange)] = []
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
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
    public func setBBCodeText(_ text: String, font: UIFont, textColor: UIColor) {
        textSubject.send(text)
        fontSubject.send(font)
        textColorSubject.send(textColor)
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        Publishers.CombineLatest3(textSubject, fontSubject, textColorSubject)
            .receive(on: DispatchQueue.main)
            .compactMap { [weak self] text, font, textColor -> NSAttributedString? in
                guard let self = self,
                      let text = text,
                      let font = font,
                      let textColor = textColor else { return nil }
                return self.processAttributedText(text, font: font, textColor: textColor)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] attributedString in
                self?.attributedText = attributedString
            }
            .store(in: &disposeBag)
    }
    
    private func processAttributedText(_ text: String, font: UIFont, textColor: UIColor) -> NSAttributedString? {
        var htmlString = text
        
        // Process RGB colors
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
        
        // Process other BBCode tags
        htmlString = htmlString
            .replacingOccurrences(of: "\\[color=#([A-Fa-f0-9]{6})\\]", with: "<font color=\"#$1\">", options: .regularExpression)
            .replacingOccurrences(of: "\\[/color\\]", with: "</font>", options: .regularExpression)
            .replacingOccurrences(of: "[b]", with: "<b>")
            .replacingOccurrences(of: "[/b]", with: "</b>")
            .replacingOccurrences(of: "\\[url=([^\\]]+)\\]([^\\[]+)\\[/url\\]", with: "<a href=\"$1\">$2</a>", options: .regularExpression)
        
        htmlString = "<span style=\"font-family: \(font.familyName); font-size: \(font.pointSize)px; color: \(textColor.hexString)\">\(htmlString)</span>"
        
        guard let data = htmlString.data(using: .utf8) else { return nil }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            let mutableString = NSMutableAttributedString(attributedString: attributedString)
            
            // Extract URLs and store them with their ranges
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
            debugPrint("Error converting BBCode to attributed string: \(error)")
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
        let matches = matches(in: string, options: [], range: range)
        var result = string
        
        for match in matches.reversed() {
            let range = match.range
            let matchText = (string as NSString).substring(with: range)
            let replacement = template(matchText)
            result = (result as NSString).replacingCharacters(in: range, with: replacement)
        }
        
        return result
    }
}
extension NSRegularExpression {
    func stringByReplacingMatches(
        in string: String,
        options: NSRegularExpression.MatchingOptions = [],
        range: NSRange,
        withTemplate template: (String) -> String
    ) -> String {
        let matches = matches(in: string, options: options, range: range)
        var result = string
        
        for match in matches.reversed() {
            let range = match.range
            let matchText = (string as NSString).substring(with: range)
            let replacement = template(matchText)
            result = (result as NSString).replacingCharacters(in: range, with: replacement)
        }
        
        return result
    }
}
