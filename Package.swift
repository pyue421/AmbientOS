// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AmbientOS",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "AmbientUI",
            type: .dynamic,
            targets: ["AmbientUI"]
        ),
    ],
    targets: [
        .target(
            name: "AmbientUI",
            path: "Sources/AmbientUI",
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
