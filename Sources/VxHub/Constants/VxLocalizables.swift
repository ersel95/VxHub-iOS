//
//  File.swift
//  VxHub
//
//  Created by furkan on 2.01.2025.
//

import Foundation

public enum VxLocalizables {
    public enum Permission {
        static public let microphoneAccessRequiredTitle = VxLocalizer.shared.localize("VxPermissions_Default_MicrophoneAccessRequiredTitle")
        static public let microphoneAccessRequiredMessage = VxLocalizer.shared.localize("VxPermissions_Default_MicrophoneAccessRequiredMessage")
        static public let microphoneAccessButtonTitle = VxLocalizer.shared.localize("VxPermissions_Default_MicrophoneAccessButtonTitle")
        static public let cameraAccessRequiredTitle = VxLocalizer.shared.localize("VxPermissions_Default_CameraAccessRequiredTitle")
        static public let cameraAccessRequiredMessage = VxLocalizer.shared.localize("VxPermissions_Default_CameraAccessRequiredMessage")
        static public let cameraAccessButtonTitle = VxLocalizer.shared.localize("VxPermissions_Default_CameraAccessButtonTitle")
        static public let settingsButtonTitle = VxLocalizer.shared.localize("VxPermissions_Default_SettingsButtonTitle")
        static public let cancelButtonTitle = VxLocalizer.shared.localize("VxPermissions_Default_CancelButtonTitle")
        static public let fileAccessRequiredTitle = VxLocalizer.shared.localize("VxPermissions_Default_FileAccessRequiredTitle")
        static public let fileAccessRequiredMessage = VxLocalizer.shared.localize("VxPermissions_Default_FileAccessRequiredMessage")
        static public let galleryAccessRequiredTitle = VxLocalizer.shared.localize("VxPermissions_Default_GalleryAccessRequiredTitle")
        static public let galleryAccessRequiredMessage = VxLocalizer.shared.localize("VxPermissions_Default_GalleryAccessRequiredMessage")
        static public let galleryAccessButtonTitle = VxLocalizer.shared.localize("VxPermissions_Default_GalleryAccessButtonTitle")
        static public let photoLibraryAccessRequiredTitle = VxLocalizer.shared.localize("VxPermissions_Default_PhotoLibraryAccessRequiredTitle")
        static public let photoLibraryAccessRequiredMessage = VxLocalizer.shared.localize("VxPermissions_Default_PhotoLibraryAccessRequiredMessage")
        static public let photoLibraryAccessButtonTitle = VxLocalizer.shared.localize("VxPermissions_Default_PhotoLibraryAccessButtonTitle")
    }
}
