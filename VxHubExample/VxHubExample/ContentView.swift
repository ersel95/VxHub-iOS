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
            }
            .navigationTitle("VxHub Examples")
        }
    }
}

#Preview {
    ContentView()
}
