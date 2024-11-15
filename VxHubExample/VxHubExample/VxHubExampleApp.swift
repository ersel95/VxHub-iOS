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
        let conf = VxHubConfig(hubId: "d182e44b-c343-4943-a556-c607bd0e46f9",
                               environment: .prod)
        VxHub.shared.initialize(
            config: conf,
            delegate: self,
            launchOptions: launchOptions,
            application: application)
        return true
    }
}

extension AppDelegate : VxHubDelegate {
    func vxHubDidInitialize() {
        debugPrint("Did init")
    }
    
    func vxHubDidStart() {
        debugPrint("Did start")
    }
    
    func vxHubDidFailWithError(error: String?) {
        debugPrint("Did fail with error ", error)
    }
}
