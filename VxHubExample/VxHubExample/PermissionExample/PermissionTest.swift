//
//  PermissionTest.swift
//  VxHubExample
//
//  Created by furkan on 3.01.2025.
//

import SwiftUI
import VxHub

struct PermissionTestsView: View {
    @State private var isCameraGranted: Bool = false
    @State private var isMicrophoneGranted: Bool = false
    @State private var isPhotoLibraryGranted: Bool = false
    
    var body: some View {
        Rectangle()
//        VStack(spacing: 20) {
//            Button(action: {
////                VxHub.shared.requestCameraPermission(from: nil) { granted in
//                    DispatchQueue.main.async {
//                        isCameraGranted = granted
//                    }
//                }
//            }) {
//                HStack {
//                    Image(systemName: "camera.fill")
//                    Text("Camera Permission")
//                }
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(isCameraGranted ? Color.green : Color.red)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//            }
//
//            Button(action: {
//                let topVc = UIApplication.shared.topViewController()
//                VxHub.shared.requestMicrophonePermission(from: topVc, askAgainIfDenied: true) { granted in
//                    DispatchQueue.main.async {
//                        isMicrophoneGranted = granted
//                    }
//                }
//            }) {
//                HStack {
//                    Image(systemName: "mic.fill")
//                    Text("Microphone Permission")
//                }
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(isMicrophoneGranted ? Color.green : Color.red)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//            }
//
//            Button(action: {
//                let topVc = UIApplication.shared.topViewController()
//                VxHub.shared.requestPhotoLibraryPermission(from: topVc, askAgainIfDenied: true) { granted in
//                    DispatchQueue.main.async {
//                        isPhotoLibraryGranted = granted
//                    }
//                }
//            }) {
//                HStack {
//                    Image(systemName: "photo.fill")
//                    Text("Photo Library Permission")
//                }
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(isPhotoLibraryGranted ? Color.green : Color.red)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//            }
//        }
//        .padding()
//        .navigationTitle("Permission Examples")
//        .onAppear {
//            isCameraGranted = VxHub.shared.isCameraPermissionGranted()
//            isMicrophoneGranted = VxHub.shared.isMicrophonePermissionGranted()
//            isPhotoLibraryGranted = VxHub.shared.isPhotoLibraryPermissionGranted()
//        }
    }
}
