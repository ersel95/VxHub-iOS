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
import Photos

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

    private func checkPhotoLibraryPrivacyDescription() -> Bool {
        let hasDescription = hasRequiredInfoPlistKey(for: "NSPhotoLibraryUsageDescription")
        if !hasDescription {
            VxLogger.shared.log("Missing NSPhotoLibraryUsageDescription in Info.plist. Photo Library permission cannot be requested.", level: .error, type: .error)
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

    //MARK: - Alert Types
    private enum PermissionAlertType {
        case camera
        case microphone
        case photoLibrary
        case fileAccess
        
        var title: String {
            switch self {
            case .camera:
                return VxLocalizables.Permission.cameraAccessRequiredTitle
            case .microphone:
                return VxLocalizables.Permission.microphoneAccessRequiredTitle
            case .photoLibrary:
                return VxLocalizables.Permission.galleryAccessRequiredTitle
            case .fileAccess:
                return VxLocalizables.Permission.fileAccessRequiredTitle
            }
        }
        
        var message: String {
            switch self {
            case .camera:
                return VxLocalizables.Permission.cameraAccessRequiredMessage
            case .microphone:
                return VxLocalizables.Permission.microphoneAccessRequiredMessage
            case .photoLibrary:
                return VxLocalizables.Permission.galleryAccessRequiredMessage
            case .fileAccess:
                return VxLocalizables.Permission.fileAccessRequiredMessage
            }
        }
    }
    
    private func showSettingsAlert(
        type: PermissionAlertType,
        from viewController: UIViewController,
        customTitle: String? = nil,
        customMessage: String? = nil,
        completion: (@Sendable () -> Void)? = nil
    ) {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            
            let alert = UIAlertController(
                title: customTitle ?? type.title,
                message: customMessage ?? type.message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: VxLocalizables.Permission.settingsButtonTitle, style: .default) { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
                completion?()
            })
            
            alert.addAction(UIAlertAction(title: VxLocalizables.Permission.cancelButtonTitle, style: .cancel) { _ in
                completion?()
            })
            
            viewController.present(alert, animated: true)
        }
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
                    self.showSettingsAlert(type: .microphone, from: vc, customTitle: title, customMessage: message)
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
                    self.showSettingsAlert(type: .camera, from: vc, customTitle: title, customMessage: message)
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

    //MARK: - Photo Library permissions
    private func getPhotoLibraryPermissionStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }

    internal func isPhotoLibraryPermissionGranted() -> Bool {
        return getPhotoLibraryPermissionStatus() == .authorized
    }

    internal func requestPhotoLibraryPermission(
        from viewController: UIViewController?,
        title: String = VxLocalizables.Permission.galleryAccessRequiredTitle,
        message: String = VxLocalizables.Permission.galleryAccessRequiredMessage,
        askAgainIfDenied: Bool = true,
        completion: @escaping @Sendable (Bool) -> Void
    ) {
        guard checkPhotoLibraryPrivacyDescription() else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        let status = getPhotoLibraryPermissionStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(status == .authorized)
                    VxLogger.shared.log("Photo Library permission request completed: \(status == .authorized)", level: .debug, type: .success)
                }
            }
        case .denied, .restricted, .limited:
            DispatchQueue.main.async {
                if let vc = viewController, askAgainIfDenied {
                    self.showSettingsAlert(type: .photoLibrary, from: vc, customTitle: title, customMessage: message)
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
}
