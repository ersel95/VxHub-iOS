//
//  VxHubExampleApp.swift
//  VxHubExample
//
//  Created by furkan on 30.10.2024.
//

import SwiftUI
import VxHub
import UIKit

@main
struct VxHubExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let conf = VxHubConfig(hubId: "4c6393d8-7c77-4c00-82bf-d6fa575e6bb6",
                               environment: .stage)
        VxHub.shared.initialize(
            config: conf,
            delegate: self,
            launchOptions: launchOptions,
            application: application)
        return true
    }
}

extension AppDelegate : VxHubDelegate {
    func VxHubDidInitialize() {
        debugPrint("Did init")
    }
    
    func VxHubDidStart() {
        debugPrint("Did start")
    }
    
    func VxHubDidFailWithError(error: String?) {
        debugPrint("Did fail with error ", error)
    }
}
