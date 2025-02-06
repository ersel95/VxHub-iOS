//
//  VxGetTicketsResponse.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 5.02.2025.
//

import Foundation

struct VxGetTicketsResponse: Codable {
    let id, category, status, state: String
    let lastMessage: String?
    let lastMessageCreatedAt: String?
    let createdAt: String
    let isSeen: Bool?
}
