//
//  File.swift
//  VxHub
//
//  Created by furkan on 1.11.2024.
//

import Foundation

@MainActor
public struct VxDeviceInfo: Codable {
    let deviceProfile: DeviceProfile?
    let appConfig: ApplicationConfig?
    var thirdPartyInfos: ThirdPartyInfo?
}
