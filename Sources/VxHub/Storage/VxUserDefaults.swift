//
//  File.swift
//  VxHub
//
//  Created by furkan on 1.11.2024.
//

import Foundation
internal extension UserDefaults {
    
    static var VxHub_localizeFile: Dictionary<String, Any> {
        get {
            return UserDefaults.standard.dictionary(forKey: #function) ?? [:]
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var VxHub_prefferedLanguage: String? {
        get {
            return UserDefaults.standard.string(forKey: #function)
        }
        set(languageCode){
            UserDefaults.standard.set(languageCode, forKey: #function)
        }
    }
    
    static var VxHub_downloadedUrls: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: #function) ?? []
        }
        set(newUrls) {
            UserDefaults.standard.set(newUrls, forKey: #function)
        }
    }
}

extension UserDefaults {
    
    static func appendDownloadedUrl(_ url: String) {
        var currentUrls = VxHub_downloadedUrls
        if !currentUrls.contains(url) {
            currentUrls.append(url)
            VxHub_downloadedUrls = currentUrls
        }
    }
    
    static func removeDownloadedUrl(_ url: String) {
        var currentUrls = VxHub_downloadedUrls
        if let index = currentUrls.firstIndex(of: url) {
            currentUrls.remove(at: index)
            VxHub_downloadedUrls = currentUrls
        }
    }
}
