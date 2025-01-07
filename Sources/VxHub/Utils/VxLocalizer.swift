//
//  File.swift
//  VxHub
//
//  Created by furkan on 1.11.2024.
//

import Foundation

public struct VxLocalizer: @unchecked Sendable {
    
    public static let shared = VxLocalizer()
    init() {}
    
    public func localize(_ key: String) -> String {
        if let localString = UserDefaults.VxHub_localizeFile[key] as? String {
            return localString.replacingOccurrences(of: "\\n", with: "\n")
            
        } else {
            return NSLocalizedString(key, comment: "")
        }
    }
    
    internal func parseToUserDefaults(_ data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                UserDefaults.VxHub_localizeFile.removeAll()
                UserDefaults.VxHub_localizeFile = json
            } else {
                throw URLError(.cannotParseResponse)
            }
        } catch {
            debugPrint("Failed to parse JSON: \(error.localizedDescription)")
        }
    }
}

