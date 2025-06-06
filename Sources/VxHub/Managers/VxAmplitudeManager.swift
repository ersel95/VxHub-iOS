//
//  File.swift
//  VxHub
//
//  Created by furkan on 4.11.2024.
//

@_implementationOnly import Amplitude
import Experiment
import Foundation

/// `VxAmplitudeManager` is a singleton class responsible for handling Amplitude and Experiment functionalities.
public class VxAmplitudeManager: @unchecked Sendable {

    // MARK: - Properties
    
    public static let shared = VxAmplitudeManager()
    private var experiment: ExperimentClient?
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
        deploymentKey: String?,
        deviceId: String,
        isSubscriber: Bool? = false
    ) {
        configureAmplitude(userId: userId, apiKey: apiKey, deviceId: deviceId)
        configureExperiment(deploymentKey: deploymentKey, deviceId: deviceId, isSubscriber: isSubscriber ?? false)
    }

    // MARK: - Event Logging

    /// Logs an event to Amplitude with optional properties.
    /// - Parameters:
    ///   - eventName: Name of the event.
    ///   - properties: Optional properties associated with the event.
    public func logEvent(eventName: String, properties: [AnyHashable: Any]? = nil) {
        Amplitude.instance().logEvent(eventName, withEventProperties: properties)
    }

    // MARK: - Experiment Management

    /// Starts the Experiment service with user properties.
    /// - Parameters:
    ///   - deviceId: The device ID.
    ///   - isSubscriber: Indicates if the user is a subscriber.
    private func startExperiment(deviceId: String, isSubscriber: Bool) {
        didStartExperiment = true
        let user = ExperimentUserBuilder()
            .userId(deviceId)
            .deviceId(deviceId)
            .userProperties([
                "isSubscriber": isSubscriber,
                "user-platform": "ios"
            ])
            .build()
        
        experiment?.start(user) { [weak self] error in
            if let error = error {
                VxLogger.shared.log("Experiment Start Error: \(error.localizedDescription)", level: .error, type: .error)

            } else {
                self?.fetchVariants(for: user)
            }
        }
    }

    /// Fetches variants for the given user.
    /// - Parameter user: The `ExperimentUser` to fetch variants for.
    private func fetchVariants(for user: ExperimentUser) {
        experiment?.fetch(user: user) { [weak self] client, error in
            guard self != nil else { return }
            if let error = error {
                VxLogger.shared.log("Experiment Fetch Variants Error: \(error.localizedDescription)", level: .error, type: .error)
            }
        }
    }

    // MARK: - Variant and Payload Retrieval

    /// Retrieves the variant type for a specific flag key.
    /// - Parameter flagKey: The flag key to retrieve the variant for.
    /// - Returns: The variant value as a `String`, or `nil` if not available.
    public func getVariantType(for flagKey: String) -> String? {
        return experiment?.variant(flagKey).value
    }

    /// Retrieves a specific value from the variant payload for a given flag key.
    /// - Parameters:
    ///   - flagKey: The flag key.
    ///   - payloadKey: The key to retrieve within the variant payload.
    /// - Returns: The value as a `String`, or `nil` if not available.
    public func getPayload(for flagKey: String) -> [String: Any]? {
        return experiment?.variant(flagKey).payload as? [String: Any]
    }

    // MARK: - Private Configuration Helpers

    /// Configures Amplitude with the provided details.
    private func configureAmplitude(userId: String, apiKey: String, deviceId: String) {
        Amplitude.instance().setUserId(userId)
        Amplitude.instance().defaultTracking.sessions = true
        Amplitude.instance().initializeApiKey(apiKey)
        Amplitude.instance().setDeviceId(deviceId)
        Amplitude.instance().eventUploadThreshold = 1
        Amplitude.instance().defaultTracking.appLifecycles = true
    }
    
    public func changeAmplitudeVid(vid: String?) {
        Amplitude.instance().setUserId(vid, startNewSession: true)
    }

    /// Configures the Experiment client if a deployment key is provided.
    private func configureExperiment(deploymentKey: String?, deviceId: String, isSubscriber: Bool) {
        guard let deploymentKey = deploymentKey else { return }
        
        experiment = Experiment.initializeWithAmplitudeAnalytics(
            apiKey: deploymentKey,
            config: ExperimentConfigBuilder().build()
        )
        startExperiment(deviceId: deviceId, isSubscriber: isSubscriber)
    }
    
    public func setLoginDatas(_ fullName: String? = nil, _ email: String? = nil) {
        let identify = AMPIdentify()
        identify.set("user-platform", value: "ios" as NSObject)
        
        if let fullName {
            identify.set("name", value: fullName as NSObject)
        }
        
        if let email {
            identify.set("email", value: email as NSObject)
        }
        
        Amplitude.instance().identify(identify)
    }
}
