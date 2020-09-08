// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TxnWatch",
    products: [
        .executable(name: "txnwatch", targets: ["TxnWatch"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/matter-labs/web3swift", from: "2.2.1")
    ],
    targets: [
        .target(name: "TxnWatch", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Web3swift", package: "web3swift")
        ])
    ]
)
