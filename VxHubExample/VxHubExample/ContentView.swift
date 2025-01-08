//
//  ContentView.swift
//  VxHubExample
//
//  Created by furkan on 30.10.2024.
//

import SwiftUI
import VxHub

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: MP3TestView()) {
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(.blue)
                        Text("MP3 Manager Tests")
                    }
                }
                
                NavigationLink(destination: PermissionTestsView()) {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.blue)
                        Text("Permission Tests")
                    }
                }
                
                NavigationLink(destination: LottieUIKitWrapper()) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text("Lottie Tests (UIKit)")
                    }
                }
                
                NavigationLink(destination: ReachabilityExample()) {
                    HStack {
                        Image(systemName: "wifi")
                            .foregroundColor(.green)
                        Text("Reachability Tests")
                    }
                }
                
                NavigationLink(destination: DebugPopupExample()) {
                    HStack {
                        Image(systemName: "exclamationmark.bubble")
                            .foregroundColor(.orange)
                        Text("Debug Popup Tests")
                    }
                }
                
                Button(action: {
                    let vc = PaywallTestViewController()
                    vc.modalPresentationStyle = .fullScreen
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootVC = window.rootViewController {
                        rootVC.present(vc, animated: true)
                    }
                }) {
                    HStack {
                        Image(systemName: "creditcard")
                            .foregroundColor(.purple)
                        Text("Paywall Test")
                    }
                }
            }
            .navigationTitle("VxHub Examples")
        }
    }
}

#Preview {
    ContentView()
}
