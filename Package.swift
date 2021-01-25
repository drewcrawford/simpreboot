// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "simpreboot",
    platforms: [.macOS("10.15.4")],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "simpreboot",
            dependencies: []),
        .target(
            name: "libpreboot",
            dependencies: []),
        .testTarget(
            name: "simprebootTests",
            dependencies: ["simpreboot"]),
        .testTarget(
            name: "libprebootTests",
            dependencies: ["libpreboot"]),
    ]
)
