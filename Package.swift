// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VxHub",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
    ],
    products: [
        // Full bundle (backward compatible) - includes everything
        .library(name: "VxHub", targets: ["VxHub"]),
        // Core only (KeychainSwift + Reachability)
        .library(name: "VxHubCore", targets: ["VxHubCore"]),
        // Individual service modules
        .library(name: "VxHubRevenueCat", targets: ["VxHubRevenueCat"]),
        .library(name: "VxHubAmplitude", targets: ["VxHubAmplitude"]),
        .library(name: "VxHubAppsFlyer", targets: ["VxHubAppsFlyer"]),
        .library(name: "VxHubOneSignal", targets: ["VxHubOneSignal"]),
        .library(name: "VxHubFirebase", targets: ["VxHubFirebase"]),
        .library(name: "VxHubGoogleSignIn", targets: ["VxHubGoogleSignIn"]),
        .library(name: "VxHubFacebook", targets: ["VxHubFacebook"]),
        .library(name: "VxHubSentry", targets: ["VxHubSentry"]),
        .library(name: "VxHubMedia", targets: ["VxHubMedia"]),
        .library(name: "VxHubBanner", targets: ["VxHubBanner"]),
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
        .package(url: "https://github.com/Daltron/NotificationBanner", branch: "master"),
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "VxHubCore",
            dependencies: [
                .product(name: "KeychainSwift", package: "keychain-swift"),
                .product(name: "Reachability", package: "Reachability.swift"),
            ],
            path: "Sources/VxHubCore",
            resources: [
                .copy("Network/mTLS/vx_mtls_certificate.p12"),
                .copy("Resources/VxInfo-STAGE.plist"),
                .copy("Resources/VxInfo-PROD.plist"),
                .process("Resources/Media.xcassets"),
                .process("Resources/en.lproj"),
                .process("Resources/PrivacyInfo.xcprivacy")
            ]
        ),

        // MARK: - Satellite Modules
        .target(
            name: "VxHubRevenueCat",
            dependencies: [
                "VxHubCore",
                .product(name: "RevenueCat", package: "purchases-ios-spm"),
            ],
            path: "Sources/VxHubRevenueCat"
        ),
        .target(
            name: "VxHubAmplitude",
            dependencies: [
                "VxHubCore",
                .product(name: "Experiment", package: "experiment-ios-client"),
                .product(name: "Amplitude", package: "Amplitude-iOS"),
            ],
            path: "Sources/VxHubAmplitude"
        ),
        .target(
            name: "VxHubAppsFlyer",
            dependencies: [
                "VxHubCore",
                .product(name: "AppsFlyerLib", package: "AppsFlyerFramework", condition: .when(platforms: [.iOS])),
            ],
            path: "Sources/VxHubAppsFlyer"
        ),
        .target(
            name: "VxHubOneSignal",
            dependencies: [
                "VxHubCore",
                .product(name: "OneSignalFramework", package: "OneSignal-iOS-SDK", condition: .when(platforms: [.iOS])),
            ],
            path: "Sources/VxHubOneSignal"
        ),
        .target(
            name: "VxHubFirebase",
            dependencies: [
                "VxHubCore",
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
            ],
            path: "Sources/VxHubFirebase"
        ),
        .target(
            name: "VxHubGoogleSignIn",
            dependencies: [
                "VxHubCore",
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
            ],
            path: "Sources/VxHubGoogleSignIn"
        ),
        .target(
            name: "VxHubFacebook",
            dependencies: [
                "VxHubCore",
                .product(name: "FacebookCore", package: "facebook-ios-sdk", condition: .when(platforms: [.iOS])),
            ],
            path: "Sources/VxHubFacebook"
        ),
        .target(
            name: "VxHubSentry",
            dependencies: [
                "VxHubCore",
                .product(name: "Sentry", package: "sentry-cocoa"),
            ],
            path: "Sources/VxHubSentry"
        ),
        .target(
            name: "VxHubMedia",
            dependencies: [
                "VxHubCore",
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "Lottie", package: "lottie-spm"),
            ],
            path: "Sources/VxHubMedia"
        ),
        .target(
            name: "VxHubBanner",
            dependencies: [
                "VxHubCore",
                .product(name: "NotificationBannerSwift", package: "NotificationBanner", condition: .when(platforms: [.iOS])),
            ],
            path: "Sources/VxHubBanner"
        ),

        // MARK: - Full Bundle (backward compatible)
        .target(
            name: "VxHub",
            dependencies: [
                "VxHubCore",
                "VxHubRevenueCat",
                "VxHubAmplitude",
                "VxHubAppsFlyer",
                "VxHubOneSignal",
                "VxHubFirebase",
                "VxHubGoogleSignIn",
                "VxHubFacebook",
                "VxHubSentry",
                "VxHubMedia",
                "VxHubBanner",
            ],
            path: "Sources/VxHub"
        ),

        // MARK: - Tests
        .testTarget(
            name: "VxHubTests",
            dependencies: ["VxHub"],
            path: "Tests/VxHubTests"
        ),
    ]
)
