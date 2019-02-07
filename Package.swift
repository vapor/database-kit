// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "database-kit",
    products: [
        .library(name: "DatabaseKit", targets: ["DatabaseKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/nio-kit.git", .branch("master")),
    ],
    targets: [
        .target(name: "DatabaseKit", dependencies: ["NIOKit"]),
        .testTarget(name: "DatabaseKitTests", dependencies: ["DatabaseKit"]),
    ]
)
