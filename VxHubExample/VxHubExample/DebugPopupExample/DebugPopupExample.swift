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
                VxHub.shared.showPopup("AI çıktısı Outfit galeasdfsafsafsadrinize kaydedildi.", type: .success, priority: 1, buttonText: "Göster") {
                    debugPrint("Bastim")
                }
            }
            
            Button("Show Function Name") {
                VxHub.shared.showPopup("AI çıktısı Outfit galerinize kaydedildi.", type: .success, priority: 0)
            }
            
            Button("Show Long Error") {
            }
        }
        .navigationTitle("Debug Popup Tests")
    }
} 
