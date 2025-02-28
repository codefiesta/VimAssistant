// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VimAssistant",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "VimAssistant",
            targets: ["VimAssistant"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/codefiesta/VimKit", from: .init(0, 4, 3))
    ],
    targets: [
        .target(
            name: "VimAssistant",
            dependencies: ["VimKit"],
            resources: [.process("Resources/")],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreML"),
                .linkedFramework("NaturalLanguage"),
                .linkedFramework("Speech")
            ]
        ),
        .testTarget(
            name: "VimAssistantTests",
            dependencies: ["VimAssistant"]
        ),
    ]
)
