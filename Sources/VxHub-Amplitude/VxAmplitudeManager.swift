//
//  File.swift
//  VxHub
//
//  Created by furkan on 4.11.2024.
//

#if canImport(Amplitude)
@_implementationOnly import Amplitude
import Foundation

/// `VxAmplitudeManager` is a singleton class responsible for handling Amplitude and Experiment functionalities.
open class VxAmplitudeManager: @unchecked Sendable {

    // MARK: - Properties
    
    public static let shared = VxAmplitudeManager()
    private(set) public var didStartExperiment = false

    // MARK: - Initialization

    /// Initializes the Amplitude and Experiment services.
    /// - Parameters:
    ///   - userId: User ID for Amplitude.
    ///   - apiKey: API key for Amplitude.
    ///   - deploymentKey: Optional deployment key for Experiment.
    ///   - deviceId: Device ID for tracking.
    ///   - isSubscriber: Optional flag indicating if the user is a subscriber.
    public func initialize(
        userId: String,
        apiKey: String,
        deviceId: String,
        isSubscriber: Bool? = false
    ) {
        configureAmplitude(userId: userId, apiKey: apiKey, deviceId: deviceId)
    }

    // MARK: - Event Logging

    /// Logs an event to Amplitude with optional properties.
    /// - Parameters:
    ///   - eventName: Name of the event.
    ///   - properties: Optional properties associated with the event.
    public func logEvent(eventName: String, properties: [AnyHashable: Any]? = nil) {
        Amplitude.instance().logEvent(eventName, withEventProperties: properties)
    }

    /// Configures Amplitude with the provided details.
    private func configureAmplitude(userId: String, apiKey: String, deviceId: String) {
        Amplitude.instance().setUserId(userId)
        Amplitude.instance().defaultTracking.sessions = true
        Amplitude.instance().initializeApiKey(apiKey)
        Amplitude.instance().setDeviceId(deviceId)
    }
}
#endif
