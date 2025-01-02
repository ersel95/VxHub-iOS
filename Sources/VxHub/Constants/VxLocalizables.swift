//
//  File.swift
//  VxHub
//
//  Created by furkan on 2.01.2025.
//

import Foundation

public enum VxLocalizables {
    public enum Permission {
        static public let microphoneAccessRequiredTitle = VxLocalizer().localize("VxPermissions_Default_MicrophoneAccessRequiredTitle")
        static public let microphoneAccessRequiredMessage = VxLocalizer().localize("VxPermissions_Default_MicrophoneAccessRequiredMessage")
        static public let microphoneAccessButtonTitle = VxLocalizer().localize("VxPermissions_Default_MicrophoneAccessButtonTitle")
        static public let cameraAccessRequiredTitle = VxLocalizer().localize("VxPermissions_Default_CameraAccessRequiredTitle")
        static public let cameraAccessRequiredMessage = VxLocalizer().localize("VxPermissions_Default_CameraAccessRequiredMessage")
        static public let cameraAccessButtonTitle = VxLocalizer().localize("VxPermissions_Default_CameraAccessButtonTitle")
        static public let settingsButtonTitle = VxLocalizer().localize("VxPermissions_Default_SettingsButtonTitle")
        static public let cancelButtonTitle = VxLocalizer().localize("VxPermissions_Default_CancelButtonTitle")
        static public let fileAccessRequiredTitle = VxLocalizer().localize("VxPermissions_Default_FileAccessRequiredTitle")
        static public let fileAccessRequiredMessage = VxLocalizer().localize("VxPermissions_Default_FileAccessRequiredMessage")
    }
}
