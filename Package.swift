// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "IndieAppGrowthKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "IndieAppGrowthKit",
            targets: ["IndieAppGrowthKit"]
        ),
    ],
    targets: [
        .target(
            name: "IndieAppGrowthKit"
        ),
        .testTarget(
            name: "IndieAppGrowthKitTests",
            dependencies: ["IndieAppGrowthKit"]
        ),
        // Runnable sample app (macOS, via `swift run IndieAppGrowthKitDemo`) that
        // integrates every SDK feature end-to-end for manual testing during
        // development. See Demo/README.md. Not part of the distributed library.
        .executableTarget(
            name: "IndieAppGrowthKitDemo",
            dependencies: ["IndieAppGrowthKit"],
            path: "Demo/IndieAppGrowthKitDemo"
        ),
    ]
)
