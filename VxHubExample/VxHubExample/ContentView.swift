//
//  ContentView.swift
//  VxHubExample
//
//  Created by furkan on 30.10.2024.
//

import SwiftUI
import VxHub
import VxHub_Appsflyer

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large) // nothing
                .foregroundStyle(.tint)
        }
        .onTapGesture {
            VxHub.shared.showPrivacy(isFullScreen: true)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
