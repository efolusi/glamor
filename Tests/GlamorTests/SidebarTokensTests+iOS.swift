import Foundation
import Testing

/// GL39: the iOS `G` carries the Mac's names, with the Mac's values, for everything the sidebar row reads. An iOS test
/// target cannot run in `swift test`, so these read the token files, which runs on the Mac.
struct SidebarTokensTestsIOS {
    private let files = TokenSource()

    /// Each colour the sidebar reads is the same design-tokens colour on both platforms.
    @Test(arguments: ["panel", "field", "placeholder", "accentSubtle", "selectedMarker", "pressed"])
    func aSidebarColourIsTheSameTokenAsOnTheMac(name: String) throws {
        let mac = try files.source("macOS/Tokens.swift"), ios = try files.source("iOS/Tokens+iOS.swift")
        let onMac = try #require(files.value(of: name, in: mac), "the Mac G has no \(name)")
        let onIOS = try #require(files.value(of: name, in: ios), "the iOS G has no \(name)")
        #expect(onIOS == onMac, "\(name): iOS \(onIOS), Mac \(onMac)")
    }

    /// The selected marker and the row's spacing are one shape on both platforms.
    @Test(arguments: ["padding", "radius", "markerWidth", "markerInset", "markerHeight"])
    func aRowMeasureIsTheSameAsOnTheMac(name: String) throws {
        let mac = try #require(files.block("Row", in: files.source("macOS/Tokens.swift")), "the Mac G has no Row")
        let ios = try #require(files.block("Row", in: files.source("iOS/Tokens+iOS.swift")), "the iOS G has no Row")
        let onMac = try #require(files.value(of: name, in: mac), "the Mac G.Row has no \(name)")
        let onIOS = try #require(files.value(of: name, in: ios), "the iOS G.Row has no \(name)")
        #expect(onIOS == onMac, "\(name): iOS \(onIOS), Mac \(onMac)")
    }

    @Test func aSectionLabelIsTheMacsTracking() throws {
        let ios = try files.source("iOS/Tokens+iOS.swift"), mac = try files.source("macOS/Tokens.swift")
        let font = try #require(files.block("Font", in: ios), "the iOS G has no Font")
        #expect(font.contains("static let sectionLabel"), "the iOS G.Font has no sectionLabel")
        let onMac = try #require(files.value(of: "sectionTracking", in: mac))
        #expect(files.value(of: "sectionTracking", in: font) == onMac)
    }

    @Test func aTouchRowHasNoFixedHeightSoLargeTextGrowsIt() throws {
        let ios = try files.source("iOS/Tokens+iOS.swift")
        #expect(!ios.contains("oneLine"), "a row height is G.touch on iOS; a fixed oneLine would clip large text")
        #expect(files.value(of: "touch", in: ios) == "CGFloat(GlamorTokens.Length.tapMin)")
    }

    @Test func theCountIsOneTypeForBothPlatforms() throws {
        let count = try files.source("Places/SidebarCount.swift")
        #expect(!count.contains("#if os("), "SidebarCount is Foundation only and is read on Mac and iOS")
        #expect(count.contains("public struct SidebarCount"))
    }
}
