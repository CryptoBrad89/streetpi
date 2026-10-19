// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "StreetPiCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v14),
    ],
    products: [
        .library(name: "StreetPiCore", targets: ["StreetPiCore"]),
    ],
    targets: [
        .target(
            name: "StreetPiCore",
            resources: [
                .process("FixtureData"),
            ]
        ),
        .testTarget(
            name: "StreetPiCoreTests",
            dependencies: ["StreetPiCore"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
