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
}
