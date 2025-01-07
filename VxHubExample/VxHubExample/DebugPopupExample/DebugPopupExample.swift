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
                debugPrint("fa: err")
                VxHub.shared.showErrorPopup("This is a test error message")
            }
            
            Button("Show Function Name") {
                VxHub.shared.showErrorPopup()
            }
            
            Button("Show Long Error") {
                VxHub.shared.showErrorPopup("This is a very long error message that will test how the popup handles multiple lines of text. It should automatically adjust its height based on the content while maintaining readability and proper layout.")
            }
        }
        .navigationTitle("Debug Popup Tests")
    }
} 
