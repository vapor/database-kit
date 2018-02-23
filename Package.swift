// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "DatabaseKit",
    products: [
        .library(name: "DatabaseKit", targets: ["DatabaseKit"]),
        .library(name: "SQL", targets: ["SQL"]),
    ],
    dependencies: [
        // ⏱ Promises and reactive-streams in Swift built for high-performance and scalability.
        .package(url: "https://github.com/vapor/async.git", from: "1.0.0-rc"),

        // 🌎 Utility package containing tools for byte manipulation, Codable, OS APIs, and debugging.
        .package(url: "https://github.com/vapor/core.git", from: "3.0.0-rc"),

        // 📦 Dependency injection / inversion of control framework.
        .package(url: "https://github.com/vapor/service.git", from: "1.0.0-rc"),
    ],
    targets: [
        .target(name: "DatabaseKit", dependencies: ["Async", "Service"]),
        .testTarget(name: "DatabaseKitTests", dependencies: ["DatabaseKit"]),
        .target(name: "SQL"),
        .testTarget(name: "SQLTests", dependencies: ["SQL"]),
    ]
)
