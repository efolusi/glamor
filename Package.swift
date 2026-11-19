// swift-tools-version:6.0
import PackageDescription

// Glamor: the native design system. One library for Mac, iPhone and iPad. Tokens live in `G`;
// sizes follow each idiom (macOS files under Sources/Glamor/macOS, iOS files under Sources/Glamor/iOS).
let package = Package(
    name: "Glamor",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [
        .library(name: "Glamor", targets: ["Glamor"]),
    ],
    targets: [
        .target(name: "Glamor", swiftSettings: [.swiftLanguageMode(.v5)]),
        .testTarget(name: "GlamorTests", dependencies: ["Glamor"], swiftSettings: [.swiftLanguageMode(.v5)]),
        // A small Mac app that shows the components in a real window. Not a product, so it never ships.
        .executableTarget(name: "GlamorGallery", dependencies: ["Glamor"], swiftSettings: [.swiftLanguageMode(.v5)]),
    ]
)
