//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 6.01.2025.
//

import Foundation

public final class BuildConfiguration: @unchecked Sendable {
    
    public init() {}

    func value(for key: String) -> String {
        guard let dictionary = Bundle.main.object(forInfoDictionaryKey: "CustomConfigurations") as? [String: String],
              let value = dictionary[key]
        else {
            fatalError("Value not found for key: \(key) in Configuration File")
        }
        
        return value
    }
}
