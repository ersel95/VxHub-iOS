//
//  VxClaimRetentionCoinGiftResponse.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 20.03.2025.
//

import Foundation

public struct VxClaimRetentionCoinGiftResponse: Codable {
    public let status: String?
    public let giftAmount: Int?
    
    enum CodingKeys: String, CodingKey {
        case status
        case giftAmount = "gift_amount"
    }
}

public struct VxClaimRetentionCoinGiftFailResponse: Codable, Error {
    public let message: String?
    public let error: String?
    public let statusCode: Int?
}
