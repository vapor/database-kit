// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "DatabaseKit",
    products: [
        .library(name: "DatabaseKit", targets: ["DatabaseKit"]),
        .library(name: "SQL", targets: ["SQL"]),
    ],
    dependencies: [
        // Swift Promises, Futures, and Streams.
        .package(url: "https://github.com/vapor/async.git", .branch("beta")),

        // Core extensions, type-aliases, and functions that facilitate common tasks.
        .package(url: "https://github.com/vapor/core.git", .branch("beta")),

        // Service container and configuration system.
        .package(url: "https://github.com/vapor/service.git", .branch("beta")),
    ],
    targets: [
        .target(name: "DatabaseKit", dependencies: ["Async", "Service"]),
        .testTarget(name: "DatabaseKitTests", dependencies: ["DatabaseKit"]),
        .target(name: "SQL"),
        .testTarget(name: "SQLTests", dependencies: ["SQL"]),
    ]
)
