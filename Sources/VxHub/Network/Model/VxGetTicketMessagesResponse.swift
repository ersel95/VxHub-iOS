//
//  VxGetTicketMessagesResponse.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 6.02.2025.
//

import Foundation


struct VxGetTicketMessagesResponse: Codable {
    let id, category: String
    let projectID: Int
    let deviceID, vid: String
    let email, name: String?
    let status, state, source, createdAt: String
    let updatedAt: String
    let messages: [Message]

    enum CodingKeys: String, CodingKey {
        case id, category
        case projectID = "projectId"
        case deviceID = "deviceId"
        case vid, email, name, status, state, source, createdAt, updatedAt, messages
    }
}

struct Message: Codable {
    let id, message, ticketID: String
    let userID: String?
    let isFromDevice: Bool
    let deviceID: String?
    let readBy: [ReadBy]
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, message
        case ticketID = "ticketId"
        case userID = "userId"
        case isFromDevice
        case deviceID = "deviceId"
        case readBy, createdAt
    }
}

struct ReadBy: Codable {
    let readAt: String
    let userID: String?
    let deviceID: String?

    enum CodingKeys: String, CodingKey {
        case readAt
        case userID = "userId"
        case deviceID = "deviceId"
    }
}
