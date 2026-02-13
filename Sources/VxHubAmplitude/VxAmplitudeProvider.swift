//
//  VxAmplitudeProvider.swift
//  VxHub
//
//  Created by VxHub on 2025.
//

import Foundation
import VxHubCore
@_implementationOnly import Amplitude
import Experiment

public final class VxAmplitudeProvider: VxAnalyticsProvider, @unchecked Sendable {

    private var experiment: ExperimentClient?
    private(set) public var didStartExperiment: Bool = false

    public init() {}

    // MARK: - VxAnalyticsProvider

    public func initialize(userId: String, apiKey: String, deploymentKey: String?, deviceId: String, isSubscriber: Bool) {
        configureAmplitude(userId: userId, apiKey: apiKey, deviceId: deviceId)
        configureExperiment(deploymentKey: deploymentKey, deviceId: deviceId, isSubscriber: isSubscriber)
    }

    public func logEvent(eventName: String, properties: [AnyHashable: Any]?) {
        Amplitude.instance().logEvent(eventName, withEventProperties: properties)
    }

    public func getVariantType(for flagKey: String) -> String? {
        return experiment?.variant(flagKey).value
    }

    public func getPayload(for flagKey: String) -> [String: Any]? {
        return experiment?.variant(flagKey).payload as? [String: Any]
    }

    public func changeVid(vid: String?) {
        Amplitude.instance().setUserId(vid, startNewSession: true)
    }

    public func setLoginDatas(_ fullName: String?, _ email: String?) {
        let identify = AMPIdentify()
        identify.set("user-platform", value: "ios" as NSObject)

        if let fullName = fullName {
            identify.set("name", value: fullName as NSObject)
        }

        if let email = email {
            identify.set("email", value: email as NSObject)
        }

        Amplitude.instance().identify(identify)
    }

    // MARK: - Private Configuration

    private func configureAmplitude(userId: String, apiKey: String, deviceId: String) {
        Amplitude.instance().setUserId(userId)
        Amplitude.instance().defaultTracking.sessions = true
        Amplitude.instance().initializeApiKey(apiKey)
        Amplitude.instance().setDeviceId(deviceId)
        Amplitude.instance().eventUploadThreshold = 1
        Amplitude.instance().defaultTracking.appLifecycles = true
    }

    private func configureExperiment(deploymentKey: String?, deviceId: String, isSubscriber: Bool) {
        guard let deploymentKey = deploymentKey else { return }

        experiment = Experiment.initializeWithAmplitudeAnalytics(
            apiKey: deploymentKey,
            config: ExperimentConfigBuilder().build()
        )
        startExperiment(deviceId: deviceId, isSubscriber: isSubscriber)
    }

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
            if error != nil {
                // Experiment start failed - logged by caller
            } else {
                self?.fetchVariants(for: user)
            }
        }
    }

    private func fetchVariants(for user: ExperimentUser) {
        experiment?.fetch(user: user) { [weak self] client, error in
            guard self != nil else { return }
            // Variants fetched or error handled by caller
        }
    }
}
