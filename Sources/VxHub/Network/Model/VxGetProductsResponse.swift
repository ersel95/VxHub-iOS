//
//  File.swift
//  VxHub
//
//  Created by furkan on 29.01.2025.
//

import Foundation

struct VxGetProductsResponse: Codable {
    let storeIdentifier: String?
    let initialBonus: Int?
    let renewalBonus: Int?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case storeIdentifier = "store_identifier"
        case initialBonus = "initial_bonus"
        case renewalBonus = "renewal_bonus"
        case type
    }
}

struct VxGetProductsErrorResponse: Codable {
    let message: String?
    let error: String?
    let statusCode: Int?
}
