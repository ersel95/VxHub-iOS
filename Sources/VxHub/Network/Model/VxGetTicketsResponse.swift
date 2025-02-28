//
//  VxGetTicketsResponse.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 5.02.2025.
//

import Foundation

public struct VxGetTicketsResponse: Codable, Sendable {
    let id, category, status, state: String
    let lastMessage: String?
    let lastMessageCreatedAt: String?
    let createdAt: String
    let isSeen: Bool?
}
