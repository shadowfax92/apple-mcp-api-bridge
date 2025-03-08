// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MacAPIBridge",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "MacAPIBridge", targets: ["MacAPIBridge"])
    ],
    dependencies: [
        // Vapor for HTTP server
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "MacAPIBridge",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .testTarget(
            name: "MacAPIBridgeTests",
            dependencies: ["MacAPIBridge"]
        )
    ]
) 