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
        .library(name: "VxHub", targets: ["VxHub"]),
        .library(name: "VxHubCore", targets: ["VxHubCore"]),
        .library(name: "VxHubRevenueCat", targets: ["VxHubRevenueCat"]),
        .library(name: "VxHubFirebase", targets: ["VxHubFirebase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/RevenueCat/purchases-ios-spm", from: "5.7.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.4.0"),
    ],
    targets: [
        // MARK: - Core (no external dependencies in light mode)
        .target(
            name: "VxHubCore",
            dependencies: [],
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

        // MARK: - Mandatory Satellite Modules
        .target(
            name: "VxHubRevenueCat",
            dependencies: [
                "VxHubCore",
                .product(name: "RevenueCat", package: "purchases-ios-spm"),
            ],
            path: "Sources/VxHubRevenueCat"
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

        // MARK: - Full Bundle (light mode - only mandatory modules)
        .target(
            name: "VxHub",
            dependencies: [
                "VxHubCore",
                "VxHubRevenueCat",
                "VxHubFirebase",
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
