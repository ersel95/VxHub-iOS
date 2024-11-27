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
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
public struct RemoteConfig : Codable, Sendable {
    let bloxOnboardingAssetUrls: String?
    let bloxSetupUrl: String?
    let bloxSetupTexts: String?
    public let showLanding: String?
    
    enum CodingKeys: String, CodingKey, Codable {
        case bloxOnboardingAssetUrls = "blox_setup_screens"
        case bloxSetupUrl = "blox_setup_url"
        case bloxSetupTexts = "blox_setup_texts"
        case showLanding = "landing_show"
    }
}
