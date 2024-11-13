//
//  File.swift
//  VxHub
//
//  Created by furkan on 13.11.2024.
//

import Foundation
import Experiment

internal final class VxExperiment: @unchecked Sendable {
    
    static let shared = VxExperiment()
    private var experiment: ExperimentClient?
    private init() {}
    
    
        // MARK: - Experiment Management
    
        /// Starts the Experiment service with user properties.
        /// - Parameters:
        ///   - deviceId: The device ID.
        ///   - isSubscriber: Indicates if the user is a subscriber.
        internal func startExperiment(deviceId: String, isSubscriber: Bool) {
            let user = ExperimentUserBuilder()
                .userId(deviceId)
                .deviceId(deviceId)
                .userProperties([
                    "isSubscriber": isSubscriber,
                    "user-platform": "ios"
                ])
                .build()
    
            experiment?.start(user) { [weak self] error in
                debugPrint("Exp started")
                if let error = error {
                    debugPrint("Experiment Start Error: \(error.localizedDescription)")
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
                debugPrint("Variants,",client.all())
                if let error = error {
                    debugPrint("Experiment Fetch Variants Error: \(error.localizedDescription)")
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
    
        /// Configures the Experiment client if a deployment key is provided.
        private func configureExperiment(deploymentKey: String?, deviceId: String, isSubscriber: Bool) {
            guard let deploymentKey = deploymentKey else { return }
    
            experiment = Experiment.initializeWithAmplitudeAnalytics(
                apiKey: deploymentKey,
                config: ExperimentConfigBuilder().build()
            )
            startExperiment(deviceId: deviceId, isSubscriber: isSubscriber)
        }
}
