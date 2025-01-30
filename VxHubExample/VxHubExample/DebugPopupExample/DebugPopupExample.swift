//
//  LottieTest.swift
//  VxHubExample
//
//  Created by furkan on 3.01.2025.
//

import SwiftUI
import VxHub

struct DebugPopupExample: View {
    var body: some View {
        List {
            Button("Show Error") {
                VxHub.shared.showPopup("test", type: .success, priority: 1, buttonText: "OK") {
                    debugPrint("Bastim")
                }
            }
            
            Button("Show Function Name") {
//                VxHub.shared.showErrorPopup()
            }
            
            Button("Show Long Error") {
            }
        }
        .navigationTitle("Debug Popup Tests")
    }
} 
