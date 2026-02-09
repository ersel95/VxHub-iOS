//
//  AppStoreResponse.swift
//  VxHub
//
//  Created by Habip Yesilyurt on 27.03.2025.
//

import Foundation

struct AppStoreResponse: Decodable {
    let results: [AppStoreInfo]
}

struct AppStoreInfo: Decodable {
    let version: String
}
