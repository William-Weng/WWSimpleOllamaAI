// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWSimpleOllamaAI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "WWSimpleOllamaAI", targets: ["WWSimpleOllamaAI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/William-Weng/WWNetworking.git", from: "1.7.3"),
    ],
    targets: [
        .target(name: "WWSimpleOllamaAI", dependencies: ["WWNetworking"], resources: [.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
