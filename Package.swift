// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kinakomochi",
    products: [
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(name: "AWSSDKSwift", url: "https://github.com/swift-aws/aws-sdk-swift.git", from: "4.0.0")
    ],
    targets: [
        .target(name: "Run", dependencies: [
            .target(name: "Kinakomochi")
        ]),
        .target(name: "Kinakomochi", dependencies: [
            .product(name: "S3", package: "AWSSDKSwift"),
        ]),
        .testTarget(name: "KinakomochiTests", dependencies: [
            .target(name: "Kinakomochi")
        ]),
    ]
)
