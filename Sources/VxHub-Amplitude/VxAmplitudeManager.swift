//
//  File.swift
//  VxHub
//
//  Created by furkan on 4.11.2024.
//

#if canImport(Amplitude)
@_implementationOnly import Amplitude
import Foundation

open class VxAmplitudeManager: @unchecked Sendable {
 
    public static let shared = VxAmplitudeManager()
    
    public func initialize(
        userId: String,
        apiKey: String,
        deviceId: String
    ) {
        Amplitude.instance().setUserId(userId)
        Amplitude.instance().defaultTracking.sessions = true
        Amplitude.instance().initializeApiKey(apiKey)
        Amplitude.instance().setDeviceId(deviceId)
    }
    
    public func logEvent(eventName: String, properties: [AnyHashable: Any]) {
        Amplitude.instance().logEvent(eventName, withEventProperties: properties)
    }
}
#endif
