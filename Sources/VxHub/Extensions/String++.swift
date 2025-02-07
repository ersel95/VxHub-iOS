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
    
    /// Converts a String to an Int using NumberFormatter
    func toInt() -> Int? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: self)?.intValue
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
    
    func formattedDateForList() -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: self) else {
            return self
        }

        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            // Bugünün tarihi ise sadece saat göster (Örn: "12:42 PM")
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            timeFormatter.locale = Locale(identifier: "en_US_POSIX")
            return timeFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            // Dün ise sadece "Dün" yaz
            return "Dün"
        } else {
            // Daha eski tarihler için "dd.MM.yyyy" formatında tarih göster
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            dateFormatter.locale = Locale(identifier: "tr_TR") // Türkçe tarih formatı
            
            return dateFormatter.string(from: date)
        }
    }
}
