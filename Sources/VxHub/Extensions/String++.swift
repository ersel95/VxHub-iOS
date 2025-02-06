//
//  File.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation

public extension String  {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    func localize() -> String {
        if let localString = UserDefaults.VxHub_localizeFile[self] as? String {
            return localString.replacingOccurrences(of: "\\n", with: "\n")
            
        } else {
            return NSLocalizedString(self, comment: "")
        }
    }
    
    func localizedData() -> String? {
        if let localString = UserDefaults.VxHub_localizeFile[self] as? String {
            return localString.replacingOccurrences(of: "\\n", with: "\n")
        } else {
            return nil
        }
    }
    
    func replaceKeyReplacing(toBeReplaced: String) -> String {
        guard self.contains("{xxx}") else { return self }
        let replacedStr = self.replacingOccurrences(of: "{xxx}", with: toBeReplaced)
        return replacedStr
    }
    
    //MARK: - URL Parsing
    func matches(pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsString = self as NSString
            let results = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
            return results.flatMap { result in
                (1..<result.numberOfRanges).map {
                    nsString.substring(with: result.range(at: $0))
                }
            }
        } catch {
            return []
        }
    }
    
    func formattedDate() -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: self) {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh.mm a"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            return formatter.string(from: date)
        }
        
        return self
    }
}
