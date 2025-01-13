//
//  File.swift
//  VxHub
//
//  Created by furkan on 13.01.2025.
//

import Foundation

internal struct VxUserSession: Codable {
    let refreshToken: String
    let accessToken: String
}
