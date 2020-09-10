// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TxnWatch",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        .executable(name: "txnwatch", targets: ["TxnWatch"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0")
    ],
    targets: [
        .target(name: "TxnWatch", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Starscream", package: "Starscream"),
            .product(name: "Rainbow", package: "Rainbow")
        ])
    ]
)
