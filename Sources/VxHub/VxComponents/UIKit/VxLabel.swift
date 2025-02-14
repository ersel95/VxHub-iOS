import UIKit
import Combine

open class VxLabel: UILabel {
    
    // MARK: - Properties
    private var disposeBag = Set<AnyCancellable>()
    private let textSubject = CurrentValueSubject<String?, Never>(nil)
    
    private var linkRanges: [(url: String, range: NSRange)] = []
    private var vxFont: VxPaywallFont?
    private var lastProcessedText: String?
    
    private var pendingText: String?
    private var pendingValues: [Any]?
    
    // MARK: - Font Override
    private var _font: UIFont?
    
    // MARK: - Text Override
    public override var text: String? {
        get { super.text }
        set {
            guard let newValue else { return }
            let localizedNewValue = newValue
            if newValue.isEmpty { return }
            
            if vxFont == nil {
                pendingText = newValue
                return
            }
            
            if let pendingValues = pendingValues {
                let processedText = applyValues(pendingValues, to: localizedNewValue)
                self.pendingValues = nil
                
                if processedText.containsFormatting() {
                    textSubject.send(processedText)
                } else {
                    super.text = processedText
                }
            } else {
                if localizedNewValue.containsFormatting() {
                    textSubject.send(localizedNewValue)
                } else {
                    super.text = localizedNewValue
                }
            }
            
            lastProcessedText = newValue
        }
    }
    
    // MARK: - Initialization
    public init(frame: CGRect = .zero, font: VxPaywallFont? = nil, fontSize: CGFloat = 14, weight: VxFontWeight = .regular) {
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
    
    public func setFont(_ font: VxPaywallFont, size: CGFloat, weight: VxFontWeight) {
        self.vxFont = font
        self._font = VxFontManager.shared.font(font: font, size: size, weight: weight)
        self.font = self._font
        
        if let pendingText = pendingText {
            self.text = pendingText
            self.pendingText = nil
        }
    }
    
    private var boldForFont: UIFont {
        guard let vxFont = vxFont else {
            return UIFont.systemFont(ofSize: font?.pointSize ?? 14, weight: .bold)
        }
        
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
        textAlignment = .left
        self.isUserInteractionEnabled = false
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
        
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        textSubject
            .receive(on: DispatchQueue.main)
            .compactMap { [weak self] text -> NSAttributedString? in
                guard let self = self,
                      let text = text else { return nil }
                if let pendingValues = pendingValues {
                    let processedText = applyValues(pendingValues, to: text)
                    self.pendingValues = nil
                    return self.processAttributedText(processedText, font: self.font!, textColor: self.textColor)
                }else{
                    return self.processAttributedText(text, font: self.font!, textColor: self.textColor)
                }
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
                                self.isUserInteractionEnabled = true // TODO: - TEST
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
        VxWebViewer.shared.present(url: url,
                                   isFullscreen: false,
                                   showCloseButton: false)
    }
}

public extension VxLabel {
    func replaceValues(_ values: [Any]?) {
        guard let values = values else {
            return
        }
        
        let currentText = self.text ?? self.attributedText?.string ?? nil
        if let currentText {
            let newText = applyValues(values, to: currentText)
            self.text = newText
        } else {
            pendingValues = values
        }
    }
    
    func applyValues(_ values: [Any], to text: String) -> String {
        return values.enumerated().reduce(text) { currentText, pair in
            let (index, value) = pair
            let key = "{{value_\(index + 1)}}"
            return currentText.replacingOccurrences(of: key, with: "\(value)")
        }
    }
}

internal extension String {
    func containsFormatting() -> Bool {
        return contains("[color") ||
            contains("[b]") ||
            contains("[url=") ||
            contains("<font") ||
            contains("<strong")
    }
}
