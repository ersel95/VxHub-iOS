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
            targets: ["VxHub"] //
        ),
        .library(
            name: "VxHub-Appsflyer",
            targets: ["VxHub-Appsflyer"]
        ),
        .library(
            name: "VxHub-Amplitude",
            targets: ["VxHub-Amplitude"]
        ),
        .library(
            name: "VxHub-Firebase",
            targets: ["VxHub-Firebase"]
        ),
        .library(
            name: "VxHub-Facebook",
            targets: ["VxHub-Facebook"]
        ),
        .library(
            name: "VxHub-OneSignal",
            targets: ["VxHub-OneSignal"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/evgenyneu/keychain-swift", from: "24.0.0"),
        .package(url: "https://github.com/RevenueCat/purchases-ios-spm", from: "5.7.0"),
        .package(url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework", from: "6.15.0"),
        .package(url: "https://github.com/OneSignal/OneSignal-iOS-SDK", from: "5.2.0"),
        .package(url: "https://github.com/amplitude/Amplitude-iOS", from: "8.22.0"),
        .package(url: "https://github.com/amplitude/experiment-ios-client", from: "1.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.4.0"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk", from: "14.1.0")
    ],
    targets: [
        .target(
            name: "VxHub",
            dependencies: [
                .product(name: "KeychainSwift", package: "keychain-swift"),
                .product(name: "RevenueCat", package: "purchases-ios-spm")
            ],
            path: "Sources/VxHub"
        ),
        .target(
            name: "VxHub-Appsflyer",
            dependencies: [
                .product(name: "AppsFlyerLib", package: "AppsFlyerFramework")
            ],
            path: "Sources/VxHub-Appsflyer"
        ),
        .target(
            name: "VxHub-Amplitude",
            dependencies: [
                .product(name: "Amplitude", package: "Amplitude-iOS"),
                .product(name: "Experiment", package: "experiment-ios-client")
            ],
            path: "Sources/VxHub-Amplitude"
        ),
        .target(
            name: "VxHub-Firebase",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk")
            ],
            path: "Sources/VxHub-Firebase"
        ),
        .target(
            name: "VxHub-Facebook",
            dependencies: [
                .product(name: "FacebookCore", package: "facebook-ios-sdk")
            ],
            path: "Sources/VxHub-Facebook"
        ),
        .target(
            name: "VxHub-OneSignal",
            dependencies: [
                .product(name: "OneSignalFramework", package: "OneSignal-iOS-SDK")
            ],
            path: "Sources/VxHub-OneSignal"
        )
    ]
)

