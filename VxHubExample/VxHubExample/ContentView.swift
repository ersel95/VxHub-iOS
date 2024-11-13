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
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
        }
        .onTapGesture {
            VxHub.shared.logAmplitudeEvent(eventName: "seen", properties: [:])
            VxHub.shared.logAmplitudeEvent(eventName: "success", properties: [:])
            VxHub.shared.logAmplitudeEvent(eventName: "failed", properties: [:])
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
