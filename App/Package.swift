// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AmbientOSApp",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "AmbientOS",
            dependencies: [
                .product(name: "AmbientUI", package: "AmbientOS"),
            ]
        ),
    ]
)
