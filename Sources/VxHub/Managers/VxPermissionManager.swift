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
    
    static let shared = VxPermissionManager()
    private init() {}
    
    func requestAttPermission(completion: @escaping(AttPermissionTypes) -> Void) {
            ATTrackingManager.requestTrackingAuthorization { status in
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
    
    @available(iOS 14, *)
    nonisolated func getIDFA() -> String? {
        guard ATTrackingManager.trackingAuthorizationStatus == .authorized else {
            return nil
        }
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
}
