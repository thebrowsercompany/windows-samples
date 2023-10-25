// swift-tools-version: 5.7

import PackageDescription

let GUILinkerSettings: [LinkerSetting] = [
    .unsafeFlags(["-Xlinker", "/SUBSYSTEM:WINDOWS"], .when(configuration: .release)),
    // Update the entry point to point to the generated swift function, this lets us keep the same main method
    // for debug/release
    .unsafeFlags(["-Xlinker", "/ENTRY:mainCRTStartup"], .when(configuration: .release)),
]
let package = Package(
    name: "WinUI3AnimationsPreview",
    products: [
        .executable(name: "WinUI3AnimationsPreview", targets: ["WinUI3AnimationsPreview"]),
    ],
    dependencies: [
        .package(path: "../Shared/CWinAppSDK"),
        .package(path: "../Shared/WinRT/Sources/UWP"),
        .package(path: "../Shared/WinRT/Sources/WinAppSDK"),
        .package(path: "../Shared/WinRT/Sources/WindowsFoundation"),
        .package(path: "../Shared/WinRT/Sources/WinUI"),
    ],
    targets: [
        .executableTarget(
            name: "WinUI3AnimationsPreview",
            dependencies: [
                "CWinAppSDK",
                "UWP",
                "WinAppSDK",
                "WindowsFoundation",
                "WinUI"
            ],
            exclude: [
                "WinUI3AnimationsPreview.exe.manifest",
            ],
            linkerSettings: GUILinkerSettings
        ),
    ]
)
