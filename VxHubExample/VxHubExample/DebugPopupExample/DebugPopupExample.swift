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
                VxHub.shared.showBanner("AI çıktısı Galerinize Başarıyla kaydedildi. ve daha sonra lorem impsum canta mouse telefo", type: .success, font: .rounded, buttonLabel: "2. adıma ilerle!") {
                    debugPrint("Go")
                }
            }
            
            Button("Show Function Name") {
                VxHub.shared.showBanner("AI çıktısı Outfit galeasdfsafsafsadrinize kaydedildi.", type: .success, font: .rounded)
                VxHub.shared.showBanner("AI çıktısı ", type: .error, font: .rounded)
                VxHub.shared.showBanner("AI çıktısı ", type: .warning, font: .rounded)
                VxHub.shared.showBanner("AI çıktısı Info ", type: .info, font: .rounded)
                VxHub.shared.showBanner("AI çıktısı Info ", type: .error, font: .rounded, buttonLabel:  "go")
            }
            
            Button("Show Long Error") {
            }
        }
        .navigationTitle("Debug Popup Tests")
    }
} 
