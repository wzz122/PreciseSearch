// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PreciseSearch",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PreciseSearch", targets: ["PreciseSearch"])
    ],
    targets: [
        .target(
            name: "PreciseSearchCore",
            path: "Sources/PreciseSearchCore"
        ),
        .executableTarget(
            name: "PreciseSearch",
            dependencies: ["PreciseSearchCore"],
            path: "Sources/PreciseSearch"
        ),
        .testTarget(
            name: "PreciseSearchCoreTests",
            dependencies: ["PreciseSearchCore"],
            path: "Tests/PreciseSearchCoreTests"
        )
    ]
)
