#if os(macOS)
import Foundation
import SwiftUI
import Testing
@testable import Glamor

/// GL32: `SidebarItem`. The look is proven in a real window (scene `sidebar-a`); these pin the interface a caller
/// sees, the words VoiceOver gets, and the source shape the window check depends on.
@MainActor
struct SidebarItemTests {
    private func source(_ path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent("Sources/Glamor").appendingPathComponent(path), encoding: .utf8)
    }

    private let place = Place(id: "host", title: "Host", symbol: "desktopcomputer")

    @Test func aPlaceGivesTheRowItsTitleAndSymbol() {
        var chosen = "other"
        let item = SidebarItem(place: place, selection: Binding(get: { chosen }, set: { chosen = $0 }))
        #expect(item.title == "Host")
        #expect(item.symbol == "desktopcomputer")
        #expect(item.count == nil)
        #expect(item.help == nil)
        chosen = "host"
    }

    @Test func aPlaceRowIsSelectedWhenTheSelectionIsItsId() {
        var chosen = "other"
        let binding = Binding(get: { chosen }, set: { chosen = $0 })
        #expect(!SidebarItem(place: place, selection: binding).isSelected)
        chosen = "host"
        #expect(SidebarItem(place: place, selection: binding).isSelected)
    }

    @Test func pressingAPlaceRowSelectsItsPlace() {
        var chosen = "other"
        let item = SidebarItem(place: place, selection: Binding(get: { chosen }, set: { chosen = $0 }))
        item.action()
        #expect(chosen == "host")
    }

    @Test func aCountedRowSpeaksItsWordsAndAnUncountedOneSpeaksNone() {
        let counted = SidebarItem("Copy", symbol: "doc", isSelected: false,
                                  count: SidebarCount(2, spoken: "2 transfers running"), action: {})
        #expect(counted.spokenValue == "2 transfers running")
        #expect(SidebarItem("Copy", symbol: "doc", isSelected: false, action: {}).spokenValue == "")
    }

    @Test func theTooltipIsTheHelpOrElseTheTitle() {
        #expect(SidebarItem("Copy", symbol: "doc", isSelected: false, action: {}).tooltip == "Copy")
        #expect(SidebarItem("Copy", symbol: "doc", isSelected: false, help: "Copy files (⌘5)", action: {}).tooltip == "Copy files (⌘5)")
    }

    @Test func aCountKeepsItsNumberAndItsSpokenWords() {
        let count = SidebarCount(12, spoken: "12 queued")
        #expect(count.value == 12)
        #expect(count.spoken == "12 queued")
        #expect(count == SidebarCount(12, spoken: "12 queued"))
        #expect(count != SidebarCount(12, spoken: "twelve queued"))
    }

    // MARK: Source shape

    /// The IA look, not `RowHighlight`'s: a `panel` fill, a hairline and the marker (the owner saw it in the mocks).
    @Test func theSelectedRowIsAPanelFillWithAHairlineAndTheMarker() throws {
        let text = try source("macOS/SidebarItemStyle.swift")
        #expect(text.contains("G.panel"))
        #expect(text.contains("strokeBorder(G.border"))
        #expect(text.contains(".selectedMarker(isSelected)"))
        #expect(!text.contains("RowHighlight"), "RowHighlight selects with accentSubtle; the sidebar selects with panel")
    }

    @Test func theRowTakesItsSizeAndGroundFromTheTokens() throws {
        let style = try source("macOS/SidebarItemStyle.swift")
        #expect(style.contains("G.Row.oneLine"))
        #expect(style.contains("G.Row.padding"))
        #expect(style.contains("on: .window"))
        #expect(style.contains("focusRingInside()"), "the ring is drawn inside the style, where the button's own focus is read")
        #expect(try source("macOS/SidebarItem.swift").contains("G.Icon.md"))
    }

    /// Copper as text is 2.72:1 on a card: a count reads in `accentFg` on `accentSubtle`, never in `accent`.
    @Test func theCountIsAccentFgOnAccentSubtleAndNeverAccentText() throws {
        let text = try source("macOS/SidebarItem.swift")
        #expect(text.contains("G.accentFg"))
        #expect(text.contains("G.accentSubtle"))
        #expect(!text.contains("G.accent)"))
        #expect(text.contains("monospacedDigit()"), "a count is tabular")
        #expect(text.contains("G.Height.pill"))
    }

    @Test func theRowHasOneNameAndTheSymbolAndCountAreNotSpoken() throws {
        let text = try source("macOS/SidebarItem.swift")
        #expect(text.contains(".accessibilityLabel(title)"))
        #expect(text.contains(".accessibilityValue(spokenValue)"))
        #expect(text.contains(".help(tooltip)"))
        #expect(text.contains(".icon(G.Icon.md"), "Image.icon hides the symbol from VoiceOver")
        #expect(text.contains(".accessibilityHidden(true)"), "the count pill is spoken through the value, not twice")
        #expect(text.contains(".accessibilityAddTraits(isSelected ? .isSelected : [])"))
    }

    @Test func theLabelAndIconGapIsTheToken() throws {
        let text = try source("macOS/SidebarItem.swift")
        #expect(text.contains("spacing: G.Space.labelIcon"))
    }
}
#endif
