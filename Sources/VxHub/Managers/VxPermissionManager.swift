//
//  File.swift
//  VxHub
//
//  Created by furkan on 1.11.2024.
//

import Foundation
import AppTrackingTransparency
import AdSupport
import AVFoundation
import UIKit
import CoreLocation

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

    //MARK: - Plist Checks
    private func hasRequiredInfoPlistKey(for key: String) -> Bool {
        return Bundle.main.object(forInfoDictionaryKey: key) != nil
    }
    
    private func checkCameraPrivacyDescription() -> Bool {
        let hasDescription = hasRequiredInfoPlistKey(for: "NSCameraUsageDescription")
        if !hasDescription {
            VxLogger.shared.log("Missing NSCameraUsageDescription in Info.plist. Camera permission cannot be requested.", level: .error, type: .error)
        }
        return hasDescription
    }
    
    private func checkMicrophonePrivacyDescription() -> Bool {
        let hasDescription = hasRequiredInfoPlistKey(for: "NSMicrophoneUsageDescription")
        if !hasDescription {
            VxLogger.shared.log("Missing NSMicrophoneUsageDescription in Info.plist. Microphone permission cannot be requested.", level: .error, type: .error)
        }
        return hasDescription
    }

    //MARK: - Mic permissions
    private func getMicrophonePermissionStatus() -> AVAudioSession.RecordPermission {
        return AVAudioSession.sharedInstance().recordPermission
    }

    internal func isMicrophonePermissionGranted() -> Bool {
        return getMicrophonePermissionStatus() == .granted
    }

    internal func requestMicrophonePermission(
        from viewController: UIViewController?, 
        title: String = VxLocalizables.Permission.microphoneAccessRequiredTitle,
        message: String = VxLocalizables.Permission.microphoneAccessRequiredMessage,
        askAgainIfDenied: Bool = true,
        completion: @escaping @Sendable (Bool) -> Void
    ) {
        guard checkMicrophonePrivacyDescription() else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        let status = getMicrophonePermissionStatus()
        
        switch status {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                    VxLogger.shared.log("Microphone permission request completed: \(granted)", level: .debug, type: .success)
                }
            }
            
        case .denied:
            DispatchQueue.main.async {
                if let vc = viewController, askAgainIfDenied {
                    self.showMicrophoneSettingsAlert(from: vc, title: title, message: message)
                }
                completion(false)
            }
            
        case .granted:
            DispatchQueue.main.async {
                completion(true)
            }
            
        @unknown default:
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
    
    private func showMicrophoneSettingsAlert(
        from viewController: UIViewController,
        title: String,
        message: String
    ) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: VxLocalizables.Permission.settingsButtonTitle, style: .default) { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            })
            
            alert.addAction(UIAlertAction(title: VxLocalizables.Permission.cancelButtonTitle, style: .cancel))
            
            viewController.present(alert, animated: true)
        }
    }

    //MARK: - Cam permissions
    private func getCameraPermissionStatus() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }

    internal func isCameraPermissionGranted() -> Bool {
        return getCameraPermissionStatus() == .authorized
    }

    internal func requestCameraPermission(
        from viewController: UIViewController?,
        title: String = VxLocalizables.Permission.cameraAccessRequiredTitle,
        message: String = VxLocalizables.Permission.cameraAccessRequiredMessage,
        askAgainIfDenied: Bool = true,
        completion: @escaping @Sendable (Bool) -> Void
    ) {
        guard checkCameraPrivacyDescription() else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        let status = getCameraPermissionStatus()
        
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                    VxLogger.shared.log("Camera permission request completed: \(granted)", level: .debug, type: .success)
                }
            }
            
        case .denied, .restricted:
            DispatchQueue.main.async {
                if let vc = viewController, askAgainIfDenied {
                    self.showCameraSettingsAlert(from: vc, title: title, message: message)
                }
                completion(false)
            }
            
        case .authorized:
            DispatchQueue.main.async {
                completion(true)
            }
            
        @unknown default:
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
    
    private func showCameraSettingsAlert(
        from viewController: UIViewController,
        title: String,
        message: String
    ) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: VxLocalizables.Permission.settingsButtonTitle, style: .default) { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            })
            
            alert.addAction(UIAlertAction(title: VxLocalizables.Permission.cancelButtonTitle, style: .cancel))
            
            viewController.present(alert, animated: true)
        }
    }

    func requestLocationPermission(completion: @escaping @Sendable (Bool) -> Void) {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            CLLocationManager().requestWhenInUseAuthorization()
        case .denied, .restricted:
            completion(false)
        case .authorizedAlways, .authorizedWhenInUse:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
}
