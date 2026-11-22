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

/// The theme switch says the action it will do, not the state it is in.
struct ThemeSwitchTests {
    @Test func labelNamesTheActionToDark() {
        #expect(ThemeSwitchWords.label(current: .light) == "Switch to the dark theme")
    }

    @Test func labelNamesTheActionToLight() {
        #expect(ThemeSwitchWords.label(current: .dark) == "Switch to the light theme")
    }

    @Test func nextIsTheOtherChoice() {
        #expect(ThemeSwitchWords.next(after: .light) == .dark)
        #expect(ThemeSwitchWords.next(after: .dark) == .light)
    }
}
#endif
