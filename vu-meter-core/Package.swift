// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "vu-meter-core",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "vu-meter-core",
            targets: ["vu-meter-core"]),
    ],
    dependencies: [
        .package(url: "https://github.com/objective-audio/audio_engine.git", branch: "master"),
        .package(url: "https://github.com/objective-audio/ui.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "vu-meter-objc",
            dependencies: [
                .product(name: "audio", package: "audio_engine")
            ]
        ),
        .target(
            name: "vu-meter-core",
            dependencies: [
                .product(name: "audio", package: "audio_engine"),
                .product(name: "ui", package: "ui"),
                "vu-meter-objc"
            ]
        ),
        .testTarget(
            name: "vu-meter-objc-tests",
            dependencies: ["vu-meter-objc"]),
        .testTarget(
            name: "vu-meter-core-tests",
            dependencies: ["vu-meter-core"]),
    ],
    cLanguageStandard: .gnu18,
    cxxLanguageStandard: .gnucxx2b
)
