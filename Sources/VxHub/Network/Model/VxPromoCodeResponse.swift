// 
//  VxPromoCodeResponse.swift
//  VxHub
//
//  Created by furkan on 31.10.2024.
//

import Foundation

struct VxPromoCodeSuccessResponse: Codable {
    let success: Bool?
    let actionType: String?
    let actionMeta: String?
    let extraData: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case actionType = "action_type"
        case actionMeta = "action_meta"
        case extraData = "extra_data"
    }
}

struct VxPromoCodeErrorResponse: Codable {
    let message: String?
    let error: String?
    let statusCode: Int?
}

enum VxPromoCodeError: Error {
    case alreadyUsed
    case invalid
    case networkError(String)
    
    var message: String {
        switch self {
        case .alreadyUsed:
            return "You have already used this promo code"
        case .invalid:
            return "Invalid promo code"
        case .networkError(let message):
            return message
        }
    }
} 
