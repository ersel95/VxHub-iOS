//
//  File.swift
//  VxHub
//
//  Created by furkan on 1.11.2024.
//

import Foundation


public struct VxDeviceInfo: Codable {
    public let vid: String?
    public let deviceProfile: DeviceProfile?
    public let appConfig: ApplicationConfig?
    public var thirdPartyInfos: ThirdPartyInfo?
}
