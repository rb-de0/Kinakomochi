// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kinakomochi",
    products: [
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-aws/aws-sdk-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "Run", dependencies: ["Kinakomochi"]),
        .target(name: "Kinakomochi", dependencies: [
            "S3"
        ]),
        .testTarget(name: "KinakomochiTests", dependencies: ["Kinakomochi"]),
    ]
)
