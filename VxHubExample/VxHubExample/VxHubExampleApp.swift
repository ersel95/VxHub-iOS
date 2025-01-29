//
//  VxHubExampleApp.swift
//  VxHubExample
//
//  Created by furkan on 30.10.2024.
//

import SwiftUI
import VxHub
import UIKit
import GoogleSignIn

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
        let conf = VxHubConfig(hubId: "fec9e0c3-b781-4fa7-b04e-cc568d906e78",
                               environment: .stage,
                               logLevel: .verbose)
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
        VxHub.shared.getProducts()
    }
    
    func vxHubDidStart() {
//        debugPrint("Did start")
    }
    
    func vxHubDidFailWithError(error: String?) {
//        debugPrint("Did fail with error ", error)
    }
    
    func vxHubDidChangeNetworkStatus(isConnected: Bool, connectionType: String) {
        NotificationCenter.default.post(name: Notification.Name("vxDidChangeNetworkStatus"), object: nil, userInfo: ["isConnected": isConnected])
    }
}
