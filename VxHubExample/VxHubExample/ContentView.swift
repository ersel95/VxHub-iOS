//
//  ContentView.swift
//  VxHubExample
//
//  Created by furkan on 30.10.2024.
//

import SwiftUI
import VxHub

struct ContentView: View {
    @State private var showPaywall = false
    
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
                
                NavigationLink(destination: VxComponentsExampleView()) {
                    HStack {
                        Image(systemName: "theatermask.and.paintbrush")
                            .foregroundColor(.blue)
                        Text("Vx SwiftUI Components Example")
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
                
                PaywallUIKitWrapper()

                SupportUIKitWrapper()
                
                PromoOfferUIKitWrapper()
            }
            .navigationTitle("VxHub Examples")
        }
    }
}

#Preview {
    ContentView()
}
