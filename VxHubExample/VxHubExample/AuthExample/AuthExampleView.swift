//
//  AuthExampleView.swift
//  VxHubExample
//

import SwiftUI
import VxHub

/// Shows the ready-made sign-in flow and the state it produces.
struct AuthExampleView: View {
    @StateObject private var auth = VxAuthObserver()
    @State private var showAuth = false
    @State private var startAtSignUp = false
    @State private var message: String?

    var body: some View {
        List {
            Section("Account") {
                if let user = auth.user {
                    LabeledContent("Email", value: user.email ?? "—")
                    LabeledContent("Verified", value: user.emailVerified ? "yes" : "no")
                    LabeledContent("Methods", value: user.providers.joined(separator: ", "))
                    LabeledContent("Balance", value: user.balance.map(String.init) ?? "—")
                    Button("Sign out", role: .destructive) {
                        Task { await VxHub.shared.signOut() }
                    }
                } else {
                    Text("Nobody is signed in.").foregroundStyle(.secondary)
                }
            }

            Section("Sign in") {
                Button("Open sign-in") {
                    startAtSignUp = false
                    showAuth = true
                }
                Button("Open registration") {
                    startAtSignUp = true
                    showAuth = true
                }
            }

            Section("Panel configuration") {
                if let config = auth.config {
                    LabeledContent("Auth enabled", value: config.authEnabled ? "yes" : "no")
                    LabeledContent("Email + password", value: config.passwordEnabled ? "yes" : "no")
                    LabeledContent("Google", value: config.googleEnabled ? "yes" : "no")
                    LabeledContent("Apple", value: config.appleEnabled ? "yes" : "no")
                    LabeledContent("Min password", value: "\(config.minPasswordLength)")
                } else {
                    Text("Not loaded — the project may not have authentication enabled.")
                        .foregroundStyle(.secondary)
                }
            }

            if let message {
                Section("Last result") {
                    Text(message).font(.footnote)
                }
            }
        }
        .navigationTitle("Authentication")
        .fullScreenCover(isPresented: $showAuth) {
            VxAuthView(
                configuration: VxAuthConfiguration(showsGuestOption: true),
                startingAt: startAtSignUp ? .signUp : .signIn,
            ) { result in
                switch result {
                case .signedIn(let user):
                    message = "Signed in as \(user.email ?? user.id)"
                case .cancelled:
                    message = "Cancelled"
                case .continuedAsGuest:
                    message = "Continued without an account"
                }
                showAuth = false
            }
        }
    }
}
