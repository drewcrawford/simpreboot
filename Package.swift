// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "simpreboot",
    platforms: [.macOS("11")],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.2"),
    ],
    targets: [
        .target(
            name: "simpreboot",
            dependencies: ["libpreboot"]),
        .target(
            name: "libpreboot",
            dependencies:[.product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .testTarget(
            name: "simprebootTests",
            dependencies: ["simpreboot"]),
        .testTarget(
            name: "libprebootTests",
            dependencies: ["libpreboot"]),
    ]
)
