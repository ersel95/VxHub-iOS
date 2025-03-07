//
//  File.swift
//  VxHub
//
//  Created by Furkan Alioglu on 7.03.2025.
//

import Foundation

struct VxApproveQrSuccessResponse: Codable {
    let success: Bool?
}

struct VxApproveQrFailResponse: Codable {
    let message: String?
    let error: String?
    let statusCode: Int?
}
