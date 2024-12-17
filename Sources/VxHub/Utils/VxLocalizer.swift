//
//  File.swift
//  VxHub
//
//  Created by furkan on 1.11.2024.
//

import Foundation

public final class VxLocalizer: @unchecked Sendable {
    public static let shared = VxLocalizer()
    private init() {}
    
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
                debugPrint("HABIP LOG LOCALIZE PARSED",json)
                UserDefaults.VxHub_localizeFile.removeAll()
                UserDefaults.VxHub_localizeFile = json
            } else {
                debugPrint("HABIP LOG COULD NOT PARSE LOCALIZE",String(data: data, encoding: .utf8) ?? "")
                throw URLError(.cannotParseResponse)
            }
        } catch {
            print("Failed to parse JSON: \(error.localizedDescription)")
        }
    }
}

