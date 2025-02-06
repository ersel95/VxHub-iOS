//
//  ReachabilityExample.swift
//  VxHubExample
//
//  Created by Furkan Alioglu on 6.01.2025.
//

import SwiftUI
import VxHub

struct ReachabilityExample: View {
    @State private var connectionStatus = "Checking..."
    @State private var backgroundColor = Color.gray.opacity(0.3)
    
    var body: some View {
        ZStack {
            backgroundColor
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text(connectionStatus)
                    .font(.title)
                    .foregroundColor(backgroundColor)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(radius: 3)
                    )
                
                Text("Current Connection Type:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(VxHub.shared.currentConnectionType)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            self.backgroundColor = VxHub.shared.isConnectedToInternet ? .green : .red
            self.connectionStatus = VxHub.shared.isConnectedToInternet ? "Connected" : "Disconnected"
            
            NotificationCenter.default.addObserver(forName: Notification.Name("vxDidChangeNetworkStatus"), object: nil, queue: .main) { notification in
                let isConnected = notification.userInfo?["isConnected"] as! Bool
                connectionStatus = isConnected ? "Connected" : "Disconnected"
                backgroundColor = isConnected ? .green.opacity(0.3) : .red.opacity(0.3)
            }
        }
    }
}


#Preview {
    ReachabilityExample()
}
