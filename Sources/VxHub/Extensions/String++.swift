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
}
