// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Semver",
    products: [
        .library(
            name: "Semver",
            targets: ["Semver"]),
    ],
    targets: [
        .target(
            name: "Semver",
            path: "Sources"),
        .testTarget(
            name: "SemverTests",
            dependencies: ["Semver"],
            path: "Tests"),
    ]
)
