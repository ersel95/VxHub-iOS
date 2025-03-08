//
//  VxGetTicketsUnseenStatusResponse.swift
//  VxHub
//
//  Created by habip on 8.03.2025.
//

import Foundation

struct VxGetTicketsUnseenStatusResponse: Codable {
    let success: Bool?
}

struct VxGetTicketsUnseenStatusFailResponse: Codable {
    let message: String?
    let error: String?
    let statusCode: Int?
}
