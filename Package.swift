// swift-tools-version:6.0
import PackageDescription

// Glamor: the native design system. GlamorMac is the Mac seed (enum K); GlamorMobile is the iPhone and iPad
// seed (enum MK). They merge into one Glamor library later (ROADMAP item 6).
let package = Package(
    name: "Glamor",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [
        .library(name: "GlamorMac", targets: ["GlamorMac"]),
        .library(name: "GlamorMobile", targets: ["GlamorMobile"]),
    ],
    targets: [
        // Text made safe to show (no escape codes, controls or direction overrides). Shared by both seeds.
        .target(name: "GlamorText", swiftSettings: [.swiftLanguageMode(.v5)]),
        .target(name: "GlamorMac", dependencies: ["GlamorText"], path: "Sources/DesignSystem", swiftSettings: [.swiftLanguageMode(.v5)]),
        .target(name: "GlamorMobile", dependencies: ["GlamorText"], path: "Sources/DesignSystemMobile", swiftSettings: [.swiftLanguageMode(.v5)]),
    ]
)
