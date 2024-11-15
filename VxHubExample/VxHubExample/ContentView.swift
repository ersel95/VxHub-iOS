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
            VxHub.shared.showPrivacy(isFullScreen: true)
            VxHub.shared.logAmplitudeEvent(eventName: "asd", properties: [:])
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
