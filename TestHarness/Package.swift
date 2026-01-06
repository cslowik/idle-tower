// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TestHarness",
    dependencies: [
        .package(path: "../IdleTowerCore"),
    ],
    targets: [
        .executableTarget(
            name: "TestHarness",
            dependencies: [
                .product(name: "IdleTowerCore", package: "IdleTowerCore"),
            ]),
    ]
)

