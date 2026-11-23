import Foundation
import SwiftUI
import Testing
import Glamor

/// Glass is for macOS 26 and iOS 26 and up. Everywhere else, and whenever the person turns on Reduce Transparency
/// or Increase Contrast, the same solid surfaces are drawn.
struct GlassTests {
    @Test func glassOnlyWhenTheSystemHasItAndNothingAsksForSolid() {
        #expect(GlassPath.choose(reduceTransparency: false, increasedContrast: false, systemHasGlass: true) == .glass)
    }

    @Test func reduceTransparencyChoosesSolid() {
        #expect(GlassPath.choose(reduceTransparency: true, increasedContrast: false, systemHasGlass: true) == .solid)
    }

    @Test func increasedContrastChoosesSolid() {
        #expect(GlassPath.choose(reduceTransparency: false, increasedContrast: true, systemHasGlass: true) == .solid)
    }

    @Test func belowTwentySixChoosesSolid() {
        #expect(GlassPath.choose(reduceTransparency: false, increasedContrast: false, systemHasGlass: false) == .solid)
    }

    @Test func theSystemCheckFollowsTheRunningOS() {
        let major = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
        #expect(GlassPath.systemHasGlass == (major >= 26))
    }
}

/// design-tokens v0.7.0 is what Glamor vendors: the halus warm glass direction.
struct VendoredGlassTokensTests {
    @Test func glassValuesComeFromV070() {
        #expect(GlamorTokens.Number.glassStrength == 0.33)
        #expect(GlamorTokens.Number.materialThickDark == 0.9472)
        let tint = GlamorTokens.Color.materialTint
        #expect(tint.light == GlamorTokens.RGBA(1.0, 0.9922, 0.9765, 1.0))
        #expect(tint.dark == GlamorTokens.RGBA(0.149, 0.1255, 0.1059, 1.0))
    }

    @Test func theScriptPinsV070() throws {
        let script = try repoFile("scripts/vendor-tokens.sh")
        #expect(script.contains("TOKENS_VERSION=\"v0.7.0\""))
        #expect(script.contains("TOKENS_COMMIT=\"ebee7d00e8d94870974c9b60d1fa565a123bb050\""))
    }

    @Test func thereIsNoGlowToken() throws {
        let tokens = try repoFile("Sources/Glamor/Generated/GlamorTokens.swift").lowercased()
        #expect(!tokens.contains("glow"))
    }

    @Test func glamorDrawsNoGlow() throws {
        let sources = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Sources/Glamor")
        let files = FileManager.default.enumerator(at: sources, includingPropertiesForKeys: nil)?.compactMap { $0 as? URL } ?? []
        var found = [String]()
        for file in files where file.pathExtension == "swift" {
            let text = try String(contentsOf: file, encoding: .utf8)
            for (n, line) in text.components(separatedBy: "\n").enumerated()
            where line.lowercased().contains("glow") && !line.trimmingCharacters(in: .whitespaces).hasPrefix("//")
                && !line.trimmingCharacters(in: .whitespaces).hasPrefix("///") {
                found.append("\(file.lastPathComponent):\(n + 1)")
            }
        }
        #expect(found.isEmpty, "no glow: \(found)")
    }

    private func repoFile(_ path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
    }
}

/// GL19: the system's `.glassProminent` paints its own label colour (light on ember in dark, 2.05:1) and ignores a
/// `foregroundStyle` set outside it. The main action draws its own glass and sets `G.onAccent` inside its style.
struct GlassMainActionLabelTests {
    private func source(_ path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent("Sources/Glamor/Glass").appendingPathComponent(path), encoding: .utf8)
    }

    @Test func theMainActionDoesNotUseTheSystemProminentStyle() throws {
        #expect(!(try source("GlassSurface.swift")).contains(".glassProminent"))
    }

    @Test func theMainActionStyleSetsTheLabelColourInsideItself() throws {
        let style = try source("GlassMainActionStyle.swift")
        #expect(style.contains(".foregroundStyle(G.onAccent)"))
        #expect(style.contains(".tint(G.accent)"))
        #expect(try source("GlassSurface.swift").contains("GlassMainActionStyle()"))
    }
}

#if os(macOS)
import AppKit

/// A filled control gets a contact shadow, never a coloured one: every shadow is black or clear.
struct ShadowColourTests {
    private func isNeutral(_ color: Color) -> Bool {
        guard let c = NSColor(color).usingColorSpace(.sRGB) else { return false }
        return c.redComponent == 0 && c.greenComponent == 0 && c.blueComponent == 0
    }

    @Test func everyShadowIsBlackOrClear() {
        let all = [G.Shadow.control, G.Shadow.panel, G.Shadow.palette, G.Shadow.hover, G.Shadow.none]
        for shadow in all { #expect(isNeutral(shadow.color)) }
    }

    @Test func theContactShadowIsSmall() {
        #expect(G.Shadow.control.radius <= 2)
        #expect(G.Shadow.control.y <= 2)
    }
}

/// The theme switch says the action it will do, not the state it is in, in the words the caller gives.
struct ThemeSwitchTests {
    @Test func englishNamesTheActionToDark() {
        #expect(ThemeSwitchWords.english.label(current: .light) == "Switch to dark theme")
    }

    @Test func englishNamesTheActionToLight() {
        #expect(ThemeSwitchWords.english.label(current: .dark) == "Switch to light theme")
    }

    @Test func indonesianNamesTheAction() {
        #expect(ThemeSwitchWords.indonesian.label(current: .light) == "Ganti ke tema gelap")
        #expect(ThemeSwitchWords.indonesian.label(current: .dark) == "Ganti ke tema terang")
    }

    @Test func aCallerCanGiveItsOwnWords() {
        let words = ThemeSwitchWords(toDark: "A", toLight: "B")
        #expect(words.label(current: .light) == "A")
        #expect(words.label(current: .dark) == "B")
    }

    /// GL16: no default language, so an Indonesian app cannot fall back to English by leaving the words out.
    @Test func wordsAreARequiredArgument() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let source = try String(contentsOf: root.appendingPathComponent("Sources/Glamor/macOS/ThemeSwitch.swift"), encoding: .utf8)
        #expect(source.contains("public init(appearance: Binding<Appearance>, words: ThemeSwitchWords)"))
        #expect(!source.contains("words: ThemeSwitchWords ="))
    }

    @Test func nextIsTheOtherChoice() {
        #expect(ThemeSwitchWords.next(after: .light) == .dark)
        #expect(ThemeSwitchWords.next(after: .dark) == .light)
    }
}

/// Glass is never inside glass, and a sheet does not add a second material over the system's.
struct GlassNestingTests {
    @Test func aSheetDrawsItsOwnGroundOnlyOnTheSolidPath() {
        #expect(GlassPath.solid.drawsOwnSheetGround)
        #expect(!GlassPath.glass.drawsOwnSheetGround)
    }

    @Test func aSegmentIsNeverGlassInsideTheGlassTrack() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let text = try String(contentsOf: root.appendingPathComponent("Sources/Glamor/macOS/Controls.swift"), encoding: .utf8)
        let start = try #require(text.range(of: "private struct SegmentItem"))
        let item = String(text[start.lowerBound...])
        #expect(!item.contains("glassSurface"), "the chosen segment is solid; its track is the glass")
        #expect(text.contains("glassSurface"))
    }
}

/// A search field on glass keeps a hairline of the control edge colour. The glass is the tint at the clear
/// material's opacity over the surfaces a field sits on. Pure black and white backdrops are not held to 3:1
/// (measured 2.1 in light over black, 1.8 in dark over white); that is a known gap reported with this change.
@MainActor
struct GlassEdgeTests {
    private func lin(_ v: Double) -> Double { v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
    private func lum(_ r: Double, _ g: Double, _ b: Double) -> Double { 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b) }

    /// The limit by design: pure black and white backdrops are out of scope; the caller adds a scrim there.
    @Test(arguments: [false, true]) func theEdgeHoldsThreeToOneOnGlassOverTheSurfacesAFieldSitsOn(dark: Bool) {
        typealias C = GlamorTokens.Color
        func pick(_ p: GlamorTokens.ColorPair) -> GlamorTokens.RGBA { dark ? p.dark : p.light }
        let tint = pick(C.materialTint), edge = pick(C.borderControl)
        let a = GlamorTokens.Number.materialClear
        for ground in [C.surfacePage, C.surfaceCard, C.surfacePanel, C.surfaceSubtle, C.surfaceSunken].map(pick) {
            let glassLum = lum(tint.red * a + ground.red * (1 - a), tint.green * a + ground.green * (1 - a), tint.blue * a + ground.blue * (1 - a))
            let edgeLum = lum(edge.red, edge.green, edge.blue)
            let ratio = (max(glassLum, edgeLum) + 0.05) / (min(glassLum, edgeLum) + 0.05)
            #expect(ratio >= 3, "dark=\(dark) ratio=\(ratio)")
        }
    }
}

/// GL18: the search fields draw their placeholder in `G.placeholder`, not the system's colour, which is nearly
/// invisible on glass. The label stays the placeholder's words, so VoiceOver still names the field.
struct SearchPlaceholderSourceTests {
    private func source(_ path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent("Sources/Glamor/macOS").appendingPathComponent(path), encoding: .utf8)
    }

    @Test func theSearchBarPromptsInThePlaceholderToken() throws {
        let text = try source("Controls.swift")
        let start = try #require(text.range(of: "public struct SearchBar"))
        let end = try #require(text.range(of: "public struct MenuPicker"))
        let bar = String(text[start.lowerBound..<end.lowerBound])
        #expect(bar.contains("prompt: Text(placeholder).foregroundStyle(G.placeholder)"))
    }

    @Test func theFilterFieldPromptsInThePlaceholderToken() throws {
        let text = try source("Lists.swift")
        let start = try #require(text.range(of: "public struct FilterField"))
        let end = try #require(text.range(of: "public enum MoreMenuWords"))
        let field = String(text[start.lowerBound..<end.lowerBound])
        #expect(field.contains("prompt: Text(placeholder).foregroundStyle(G.placeholder)"))
    }

    @Test func thePlaceholderIsTheMutedTextToken() throws {
        let tokens = try source("Tokens.swift")
        #expect(tokens.contains("public static let placeholder = Color(T.textMuted)"))
    }
}
#endif
