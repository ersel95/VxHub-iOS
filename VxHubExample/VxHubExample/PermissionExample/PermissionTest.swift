//
//  PermissionTest.swift
//  VxHubExample
//
//  Created by furkan on 3.01.2025.
//

import SwiftUI
import VxHub

import SwiftUI

public struct VxComponentsExampleView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            VxTextView(
                text: "This is [b]bold[/b] and [color=#FF0000]red[/color] text",
                font: .rounded,
                fontSize: 16,
                weight: .regular
            )
            
            VxButtonView(
                title: "Tap [b]here[/b] to continue",
                font: .rounded,
                fontSize: 16,
                weight: .regular,
                backgroundColor: .blue,
                foregroundColor: .white
            ) {
                print("Button tapped!")
            }
            
            VxTextView(
                text: "Visit our [url=https://example.com]website[/url]",
                font: .rounded,
                fontSize: 14,
                weight: .regular,
                textColor: .blue
            )
        }
        .padding()
    }
}

#Preview {
    VxComponentsExampleView()
}
