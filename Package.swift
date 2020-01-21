// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Semver",
    products: [
        .library(
            name: "Semver",
            targets: ["Semver"])
    ],
    targets: [
        .target(
            name: "Semver",
            path: "Sources"),
        .testTarget(
            name: "SemverTests",
            dependencies: ["Semver"],
            path: "Tests")
    ],
    swiftLanguageVersions: [.version("5.1")]
)
