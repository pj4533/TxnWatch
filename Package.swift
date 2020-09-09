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
        .package(name: "Web3", url: "https://github.com/Boilertalk/Web3.swift.git", from: "0.4.0")
    ],
    targets: [
        .target(name: "TxnWatch", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Starscream", package: "Starscream"),
            .product(name: "Web3PromiseKit", package: "Web3"),
            .product(name: "Web3ContractABI", package: "Web3"),
            "Web3"
        ])
    ]
)
