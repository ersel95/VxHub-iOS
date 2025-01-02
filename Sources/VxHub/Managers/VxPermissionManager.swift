//
//  File.swift
//  VxHub
//
//  Created by furkan on 1.11.2024.
//

import Foundation
import AppTrackingTransparency
import AdSupport

final internal class VxPermissionManager:  @unchecked Sendable{
    public init() {}
    
    func requestAttPermission(completion: @escaping @Sendable (AttPermissionTypes) -> Void) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                defer { dispatchGroup.leave() }
                switch status {
                case .authorized:
                    completion(.granted)
                case .denied:
                    completion(.rejected)
                case .notDetermined:
                    completion(.notDetermined)
                case .restricted:
                    completion(.restricted)
                @unknown default:
                    debugPrint("Unknown")
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            VxLogger.shared.log("ATT permission request completed.", level: .debug, type: .success)
        }
    }

    
    @available(iOS 14, *)
    func getIDFA() -> String? {
        guard ATTrackingManager.trackingAuthorizationStatus == .authorized else {
            return nil
        }
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
}
