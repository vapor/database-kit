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
        .package(url: "https://github.com/vapor/async.git", "1.0.0-beta.1"..<"1.0.0-beta.2"),

        // Core extensions, type-aliases, and functions that facilitate common tasks.
        .package(url: "https://github.com/vapor/core.git", "3.0.0-beta.2"..<"3.0.0-beta.3"),

        // Service container and configuration system.
        .package(url: "https://github.com/vapor/service.git", "1.0.0-beta.2"..<"1.0.0-beta.3"),
    ],
    targets: [
        .target(name: "DatabaseKit", dependencies: ["Async", "Service"]),
        .testTarget(name: "DatabaseKitTests", dependencies: ["DatabaseKit"]),
        .target(name: "SQL"),
        .testTarget(name: "SQLTests", dependencies: ["SQL"]),
    ]
)
