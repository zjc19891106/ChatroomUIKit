// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatroomUIKit",
    defaultLocalization: .init("en"),
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ChatroomUIKit",
            targets: ["ChatroomUIKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/kakaopensource/KakaJSON", from: "1.1.2"),
    ],
    targets: [
            .target(
                name: "ChatroomUIKit",
                dependencies: [])
        ]
)
