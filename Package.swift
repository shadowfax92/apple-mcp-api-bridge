// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CalendarAPIBridge",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "CalendarAPIBridge", targets: ["CalendarAPIBridge"])
    ],
    dependencies: [
        // Vapor for HTTP server
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "CalendarAPIBridge",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .testTarget(
            name: "CalendarAPIBridgeTests",
            dependencies: ["CalendarAPIBridge"]
        )
    ]
) 