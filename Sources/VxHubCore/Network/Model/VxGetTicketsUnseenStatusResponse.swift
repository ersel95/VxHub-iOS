//
//  VxGetTicketsUnseenStatusResponse.swift
//  VxHub
//
//  Created by habip on 8.03.2025.
//

import Foundation

struct VxGetTicketsUnseenStatusResponse: Codable {
    let status: String?
    let unseenResponse: Bool?
    
    enum CodingKeys: String, CodingKey {
        case status
        case unseenResponse = "unseen_response"
    }
}

struct VxGetTicketsUnseenStatusFailResponse: Codable {
    let message: String?
    let error: String?
    let statusCode: Int?
}
