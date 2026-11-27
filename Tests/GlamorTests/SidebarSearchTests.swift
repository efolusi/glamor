#if os(macOS)
import Foundation
import SwiftUI
import Testing
@testable import Glamor

/// GL34: `SidebarSearch`, the capsule that opens ⌘K. The look and the placeholder contrast are proven in a real
/// window (scene `sidebar-a`) and in `SidebarContrastTests`; these pin the interface and the words.
@MainActor
struct SidebarSearchTests {
    private func source(_ path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent("Sources/Glamor").appendingPathComponent(path), encoding: .utf8)
    }

    @Test func theDefaultWordIsSearchInEnglishAndCariInIndonesian() {
        #expect(GlamorText.string(.searchTitle, language: "en") == "Search")
        #expect(GlamorText.string(.searchTitle, language: "id") == "Cari")
        #expect(SidebarSearch(action: {}).title == GlamorText.string(.searchTitle))
    }

    @Test func aCallerTitleReplacesTheDefaultAndTheHintDefaultsToCommandK() {
        let search = SidebarSearch(title: "Find a host", action: {})
        #expect(search.title == "Find a host")
        #expect(search.shortcut == "⌘K")
        #expect(SidebarSearch(shortcut: "⌘F", action: {}).shortcut == "⌘F")
    }

    /// The shortcut is in the tooltip, and the badge is hidden from VoiceOver: it is not spoken twice.
    @Test func theTooltipCarriesTheShortcut() {
        #expect(SidebarSearch(title: "Search", action: {}).tooltip == "Search (⌘K)")
    }

    @Test func pressingItRunsTheCallersAction() {
        var opened = 0
        SidebarSearch(action: { opened += 1 }).action()
        #expect(opened == 1)
    }

    // MARK: Source shape

    @Test func theLookIsAFieldFilledCapsuleWithAControlEdgeAndAThirtyTwoHighBody() throws {
        let style = try source("macOS/SidebarSearchStyle.swift")
        #expect(style.contains("G.field"))
        #expect(style.contains("Capsule()"))
        #expect(style.contains("G.controlEdge"))
        #expect(style.contains("G.Height.control32"))
        #expect(style.contains("focusRingCapsule()"))
        #expect(!style.contains("RoundedRectangle"), "GL41: controls of this kind are pills")
    }

    @Test func theLabelIsThePlaceholderColourAndTheGlyphIsTextThree() throws {
        let item = try source("macOS/SidebarSearch.swift")
        #expect(item.contains("magnifyingglass"))
        #expect(item.contains("G.Icon.md"))
        #expect(item.contains("spacing: G.Space.labelIcon"))
        #expect(item.contains("G.text3"), "the glyph")
        let style = try source("macOS/SidebarSearchStyle.swift")
        #expect(style.contains("G.placeholder"), "the label at rest; text2 under the pointer")
    }

    @Test func itHasOneNameAndTheBadgeIsNotSpokenTwice() throws {
        let text = try source("macOS/SidebarSearch.swift")
        #expect(text.contains(".accessibilityLabel(title)"))
        #expect(text.contains("ShortcutBadge(text: shortcut)"))
        #expect(text.contains(".accessibilityHidden(true)"))
        #expect(text.contains(".help(tooltip)"))
    }
}
#endif
