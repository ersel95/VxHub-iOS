//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 7.01.2025.
//

import Foundation

extension Array where Element == [String: AnyObject] {
    func element<T>(for key: CFString) -> T? {
        for dictElement in self {
            if let value = dictElement[key as String] as? T {
                return value
            }
        }
        return nil
    }
}

