// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "DatabaseKit",
    products: [
        .library(name: "DatabaseKit", targets: ["DatabaseKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "DatabaseKit", dependencies: ["NIO"]),
        .testTarget(name: "DatabaseKitTests", dependencies: ["DatabaseKit"]),
    ]
)
