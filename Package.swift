// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VxHub",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "VxHub",
            targets: ["VxHub"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/amplitude/experiment-ios-client", from: "1.13.7"),
        .package(url: "https://github.com/evgenyneu/keychain-swift", from: "24.0.0"),
        .package(url: "https://github.com/RevenueCat/purchases-ios-spm", from: "5.7.0"),
        .package(url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework", from: "6.15.0"),
        .package(url: "https://github.com/OneSignal/OneSignal-iOS-SDK", from: "5.2.0"),
        .package(url: "https://github.com/amplitude/Amplitude-iOS", from: "8.22.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.4.0"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk", from: "14.1.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage", from: "5.2.0"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.0"),
        .package(url: "https://github.com/ashleymills/Reachability.swift", from: "5.2.0"),
        .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.43.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.0.0"),
        .package(url: "https://github.com/Daltron/NotificationBanner", branch: "master")
    ],
    targets: [
        .target(
            name: "VxHub",
            dependencies: [
                .product(name: "KeychainSwift", package: "keychain-swift"),
                .product(name: "RevenueCat", package: "purchases-ios-spm"),
                .product(name: "AppsFlyerLib", package: "AppsFlyerFramework"),
                .product(name: "Experiment", package: "experiment-ios-client"),
                .product(name: "Amplitude", package: "Amplitude-iOS"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .product(name: "OneSignalFramework", package: "OneSignal-iOS-SDK"),
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "Lottie", package: "lottie-spm"),
                .product(name: "Reachability", package: "Reachability.swift"),
                .product(name: "Sentry", package: "sentry-cocoa"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "NotificationBannerSwift", package: "NotificationBanner")
            ],
            path: "Sources/VxHub",
            resources: [
                .copy("Network/mTLS/vx_mtls_certificate.p12"),
                .copy("Resources/VxInfo-STAGE.plist"),
                .copy("Resources/VxInfo-PROD.plist"),
                .process("Resources/Media.xcassets")
            ]
        )
    ]
)


