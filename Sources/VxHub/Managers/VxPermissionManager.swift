#if os(iOS)
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

/// VxPermissionManager handles various system permissions in a safe way.
///
/// Important Note:
/// This manager includes functionality for various system permissions (Camera, Microphone, Photo Library).
/// If you plan to use any of these permissions in your app, you MUST add the corresponding usage description
/// to your app's Info.plist:
///
/// - Camera: NSCameraUsageDescription
/// - Microphone: NSMicrophoneUsageDescription
/// - Photo Library: NSPhotoLibraryUsageDescription
///
/// If you don't plan to use a particular permission, you can safely ignore the corresponding Info.plist requirement.
/// The permission request will fail gracefully if the required description is missing, and in DEBUG builds,
/// you'll see a warning popup indicating which Info.plist key needs to be added if you want to use that permission.
///
final internal class VxPermissionManager:  @unchecked Sendable{
    public init() {}
    
    func requestAttPermission(completion: @escaping @Sendable (AttPermissionTypes) -> Void) {
//        let dispatchGroup = DispatchGroup()
//        dispatchGroup.enter()
//        
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
//                defer { dispatchGroup.leave() }
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
        
//        dispatchGroup.notify(queue: .main) {
//            VxLogger.shared.log("ATT permission request completed.", level: .debug, type: .success)
//        }
    }

    
    @available(iOS 14, *)
    func getIDFA() -> String? {
        guard ATTrackingManager.trackingAuthorizationStatus == .authorized else {
            return nil
        } 
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }

    //MARK: - Plist Checks
//    private func hasRequiredInfoPlistKey(for key: String) -> Bool {
//        let hasDescription = Bundle.main.object(forInfoDictionaryKey: key) != nil
//        return hasDescription
//    }
    
//    private func checkCameraPrivacyDescription() -> Bool {
//        return hasRequiredInfoPlistKey(for: "NSCameraUsageDescription")
//    }
//    
//    private func checkMicrophonePrivacyDescription() -> Bool {
//        return hasRequiredInfoPlistKey(for: "NSMicrophoneUsageDescription")
//    }
//
//    private func checkPhotoLibraryPrivacyDescription() -> Bool {
//        return hasRequiredInfoPlistKey(for: "NSPhotoLibraryUsageDescription")
//    }

    //MARK: - Mic permissions
//    private func getMicrophonePermissionStatus() -> AVAudioSession.RecordPermission {
//        return AVAudioSession.sharedInstance().recordPermission
//    }
//
//    internal func isMicrophonePermissionGranted() -> Bool {
//        return getMicrophonePermissionStatus() == .granted
//    }

    //MARK: - Alert Types
//    private enum PermissionAlertType {
//        case camera
//        case microphone
//        case photoLibrary
//        case fileAccess
//        
//        var title: String {
//            switch self {
//            case .camera:
//                return VxLocalizables.Permission.cameraAccessRequiredTitle
//            case .microphone:
//                return VxLocalizables.Permission.microphoneAccessRequiredTitle
//            case .photoLibrary:
//                return VxLocalizables.Permission.galleryAccessRequiredTitle
//            case .fileAccess:
//                return VxLocalizables.Permission.fileAccessRequiredTitle
//            }
//        }
//        
//        var message: String {
//            switch self {
//            case .camera:
//                return VxLocalizables.Permission.cameraAccessRequiredMessage
//            case .microphone:
//                return VxLocalizables.Permission.microphoneAccessRequiredMessage
//            case .photoLibrary:
//                return VxLocalizables.Permission.galleryAccessRequiredMessage
//            case .fileAccess:
//                return VxLocalizables.Permission.fileAccessRequiredMessage
//            }
//        }
//    }
//    
//    private func showSettingsAlert(
//        type: PermissionAlertType,
//        from viewController: UIViewController,
//        customTitle: String? = nil,
//        customMessage: String? = nil,
//        completion: (@Sendable () -> Void)? = nil
//    ) {
//        DispatchQueue.main.async {
//            
//            let alert = UIAlertController(
//                title: customTitle ?? type.title,
//                message: customMessage ?? type.message,
//                preferredStyle: .alert
//            )
//            
//            alert.addAction(UIAlertAction(title: VxLocalizables.Permission.settingsButtonTitle, style: .default) { _ in
//                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
//                    UIApplication.shared.open(settingsUrl)
//                }
//                completion?()
//            })
//            
//            alert.addAction(UIAlertAction(title: VxLocalizables.Permission.cancelButtonTitle, style: .cancel) { _ in
//                completion?()
//            })
//            
//            viewController.present(alert, animated: true)
//        }
//    }
//
//    internal func requestMicrophonePermission(
//        from viewController: UIViewController?, 
//        title: String = VxLocalizables.Permission.microphoneAccessRequiredTitle,
//        message: String = VxLocalizables.Permission.microphoneAccessRequiredMessage,
//        askAgainIfDenied: Bool = true,
//        completion: @escaping @Sendable (Bool) -> Void
//    ) {
//        if !checkMicrophonePrivacyDescription() {
//            #if DEBUG
//            VxLogger.shared.error("⚠️ Add NSMicrophoneUsageDescription to Info.plist if you plan to use microphone permissions")
//            #endif
//            DispatchQueue.main.async {
//                completion(false)
//            }
//            return
//        }
//        
//        let status = getMicrophonePermissionStatus()
//        
//        switch status {
//        case .undetermined:
//            AVAudioSession.sharedInstance().requestRecordPermission { granted in
//                DispatchQueue.main.async {
//                    completion(granted)
//                    VxLogger.shared.log("Microphone permission request completed: \(granted)", level: .debug, type: .success)
//                }
//            }
//            
//        case .denied:
//            DispatchQueue.main.async {
//                if let vc = viewController, askAgainIfDenied {
//                    self.showSettingsAlert(type: .microphone, from: vc, customTitle: title, customMessage: message)
//                }
//                completion(false)
//            }
//            
//        case .granted:
//            DispatchQueue.main.async {
//                completion(true)
//            }
//            
//        @unknown default:
//            DispatchQueue.main.async {
//                completion(false)
//            }
//        }
//    }
//
//    //MARK: - Cam permissions
//    private func getCameraPermissionStatus() -> AVAuthorizationStatus {
//        return AVCaptureDevice.authorizationStatus(for: .video)
//    }
//
//    internal func isCameraPermissionGranted() -> Bool {
//        return getCameraPermissionStatus() == .authorized
//    }
//
//    internal func requestCameraPermission(
//        from viewController: UIViewController?,
//        title: String = VxLocalizables.Permission.cameraAccessRequiredTitle,
//        message: String = VxLocalizables.Permission.cameraAccessRequiredMessage,
//        askAgainIfDenied: Bool = true,
//        completion: @escaping @Sendable (Bool) -> Void
//    ) {
//        if !checkCameraPrivacyDescription() {
//            #if DEBUG
//            VxLogger.shared.error("⚠️ Add NSCameraUsageDescription to Info.plist if you plan to use camera permissions")
//            #endif
//            DispatchQueue.main.async {
//                completion(false)
//            }
//            return
//        }
//        
//        let status = getCameraPermissionStatus()
//        
//        switch status {
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                DispatchQueue.main.async {
//                    completion(granted)
//                    VxLogger.shared.log("Camera permission request completed: \(granted)", level: .debug, type: .success)
//                }
//            }
//            
//        case .denied, .restricted:
//            DispatchQueue.main.async {
//                if let vc = viewController, askAgainIfDenied {
//                    self.showSettingsAlert(type: .camera, from: vc, customTitle: title, customMessage: message)
//                }
//                completion(false)
//            }
//            
//        case .authorized:
//            DispatchQueue.main.async {
//                completion(true)
//            }
//            
//        @unknown default:
//            DispatchQueue.main.async {
//                completion(false)
//            }
//        }
//    }
//
//    //MARK: - Photo Library permissions
//    private func getPhotoLibraryPermissionStatus() -> PHAuthorizationStatus {
//        return PHPhotoLibrary.authorizationStatus()
//    }
//
//    internal func isPhotoLibraryPermissionGranted() -> Bool {
//        return getPhotoLibraryPermissionStatus() == .authorized
//    }
//
//    internal func requestPhotoLibraryPermission(
//        from viewController: UIViewController?,
//        title: String = VxLocalizables.Permission.galleryAccessRequiredTitle,
//        message: String = VxLocalizables.Permission.galleryAccessRequiredMessage,
//        askAgainIfDenied: Bool = true,
//        completion: @escaping @Sendable (Bool) -> Void
//    ) {
//        if !checkPhotoLibraryPrivacyDescription() {
//            #if DEBUG
//            VxLogger.shared.error("⚠️ Add NSPhotoLibraryUsageDescription to Info.plist if you plan to use photo library permissions")
//            #endif
//            DispatchQueue.main.async {
//                completion(false)
//            }
//            return
//        }
//        
//        let status = getPhotoLibraryPermissionStatus()
//        switch status {
//        case .notDetermined:
//            PHPhotoLibrary.requestAuthorization { status in
//                DispatchQueue.main.async {
//                    completion(status == .authorized)
//                    VxLogger.shared.log("Photo Library permission request completed: \(status == .authorized)", level: .debug, type: .success)
//                }
//            }
//        case .denied, .restricted, .limited:
//            DispatchQueue.main.async {
//                if let vc = viewController, askAgainIfDenied {
//                    self.showSettingsAlert(type: .photoLibrary, from: vc, customTitle: title, customMessage: message)
//                }
//                completion(false)
//            }
//        case .authorized:
//            DispatchQueue.main.async {
//                completion(true)
//            }
//        @unknown default:
//            DispatchQueue.main.async {
//                completion(false)
//            }
//        }
//    }
}
#endif
