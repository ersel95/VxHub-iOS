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
        case actionType = "action_type" //MARK: VxPromoCdeActionTypes
        case actionMeta = "action_meta"
        case extraData = "extra_data"
    }
}

public struct VxPromoCodeErrorResponse: Codable, Sendable {
    public let message: String?
    let error: String?
    let statusCode: Int?

    init(message: String? = nil, error: String? = nil, statusCode: Int? = nil) {
        self.message = message
        self.error = error
        self.statusCode = statusCode
    }
}

public struct VxPromoCode: Codable, Sendable {
    public let error: VxPromoCodeErrorResponse?
    public let data: VxPromoCodeData?
    
    init(error: VxPromoCodeErrorResponse? = nil, data: VxPromoCodeData? = nil) {
        self.error = error
        self.data = data
    }
}

public struct VxPromoCodeData: Codable, Sendable {
    let actionType: VxPromoCodeActionTypes?
    let actionMeta: VxPromoCodeActionMeta?
    let extraData: [String: String]?
    
    init(actionType: VxPromoCodeActionTypes? = nil,
         actionMeta: VxPromoCodeActionMeta? = nil,
         extraData: [String : String]? = nil) {
        self.actionType = actionType
        self.actionMeta = actionMeta
        self.extraData = extraData
    }
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

public enum VxPromoCodeActionTypes: String, Codable, Sendable {
    case discount
    case premium
    case coin
}

public struct VxPromoCodeActionMeta: Codable, Sendable {
    var packageName: String?
    var durationInDays: Int?
    var coinAmount: Int?
    
    init(data: String?,
         actionType: VxPromoCodeActionTypes) {
        self.packageName = nil
        self.durationInDays = nil
        self.coinAmount = nil
        
        guard let data else { return }
        
        switch actionType {
        case .discount:
            self.packageName = data
            
        case .premium:
            self.durationInDays = data.toInt()
            
        case .coin:
            self.coinAmount = data.toInt()
        }
    }
}
