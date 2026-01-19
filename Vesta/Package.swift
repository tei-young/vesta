// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Vesta",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Vesta",
            targets: ["Vesta"]
        )
    ],
    dependencies: [
        // Firebase SDK
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "10.20.0"
        )
    ],
    targets: [
        .target(
            name: "Vesta",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ],
            path: "."
        )
    ]
)
