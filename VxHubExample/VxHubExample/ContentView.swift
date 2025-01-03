//
//  ContentView.swift
//  VxHubExample
//
//  Created by furkan on 30.10.2024.
//

import SwiftUI
import VxHub

struct ContentView: View {
    @State private var isCameraGranted: Bool = false
    @State private var isMicrophoneGranted: Bool = false
    @State private var isPhotoLibraryGranted: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                VxHub.shared.requestCameraPermission(from: nil) { granted in
                    isCameraGranted = granted
                }
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Camera Permission")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isCameraGranted ? Color.green : Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Button(action: {
                let topVc = UIApplication.shared.topViewController()
                VxHub.shared.requestMicrophonePermission(from: topVc, askAgainIfDenied: true) { granted in
                    isMicrophoneGranted = granted
                }
            }) {
                HStack {
                    Image(systemName: "mic.fill")
                    Text("Microphone Permission")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isMicrophoneGranted ? Color.green : Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Button(action: {
                let topVc = UIApplication.shared.topViewController()
                VxHub.shared.requestPhotoLibraryPermission(from: topVc, askAgainIfDenied: true) { granted in
                    isPhotoLibraryGranted = granted
                }
            }) {
                HStack {
                    Image(systemName: "photo.fill")
                    Text("Photo Library Permission")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isPhotoLibraryGranted ? Color.green : Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            isCameraGranted = VxHub.shared.isCameraPermissionGranted()
            isMicrophoneGranted = VxHub.shared.isMicrophonePermissionGranted()
            isPhotoLibraryGranted = VxHub.shared.isPhotoLibraryPermissionGranted()
        }
    }
}

#Preview {
    ContentView()
}
public struct RemoteConfig : Codable {
    let bloxOnboardingAssetUrls: String?
    let bloxSetupUrl: String?
    let bloxSetupTexts: String?
    public let showLanding: String?
    
    enum CodingKeys: String, CodingKey, Codable {
        case bloxOnboardingAssetUrls = "blox_setup_screens"
        case bloxSetupUrl = "blox_setup_url"
        case bloxSetupTexts = "blox_setup_texts"
        case showLanding = "landing_show"
    }
}
