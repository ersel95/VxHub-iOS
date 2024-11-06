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
    
}
