// swift-tools-version: 5.9

import PackageDescription
let package = Package(
    name: "CWinAppSDK",
    products: [
        .library(
            name: "CWinAppSDK",
            targets: ["CWinAppSDK"]
        ),
    ],
    targets: [
        .systemLibrary(
            name: "CWinAppSDK"
        ),
    ]
)
