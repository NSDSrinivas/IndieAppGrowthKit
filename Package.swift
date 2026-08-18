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
    ]
)
