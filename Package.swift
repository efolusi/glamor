// swift-tools-version:6.0
import PackageDescription

// Glamor: the native design system. One library for Mac, iPhone and iPad. Tokens live in `G`;
// sizes follow each idiom (macOS files under Sources/Glamor/macOS, iOS files under Sources/Glamor/iOS).
// Words the library says itself (VoiceOver names, tooltips, defaults) are written in Sources/Glamor/Resources/Localizable.xcstrings, en and id.
// The targets ship the <lang>.lproj/Localizable.strings that scripts/generate-strings.py writes from it: not every toolchain compiles a .xcstrings.
let package = Package(
    name: "Glamor",
    defaultLocalization: "en",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [
        .library(name: "Glamor", targets: ["Glamor"]),
    ],
    targets: [
        .target(name: "Glamor", exclude: ["Resources/Localizable.xcstrings"], resources: [.process("Resources")], swiftSettings: [.swiftLanguageMode(.v5)]),
        .testTarget(name: "GlamorTests", dependencies: ["Glamor"], swiftSettings: [.swiftLanguageMode(.v5)]),
        // A small Mac app that shows the components in a real window. Not a product, so it never ships.
        .executableTarget(name: "GlamorGallery", dependencies: ["Glamor"], exclude: ["Resources/Localizable.xcstrings"], resources: [.process("Resources")], swiftSettings: [.swiftLanguageMode(.v5)]),
    ]
)
