//
//  VxCreateTicketSuccessResponse.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 6.02.2025.
//

import Foundation

struct VxCreateTicketSuccessResponse: Codable {
    let id: String
    let category: String
    let status: String
    let state: String
    let createdAt: String
}
