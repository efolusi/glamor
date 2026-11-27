#if os(macOS)
import AppKit
import CoreText
import Foundation
import SwiftUI
import Testing
@testable import Glamor

/// GL38: `SidebarRail` and `SidebarColumn` (variant B, the narrow window). What they draw is proven in a real window
/// (scene `sidebar-b`); these pin the areas the rail builds from the registry, the sizes, and the source shape the
/// window check depends on.
@MainActor
struct SidebarRailTests {
    private func source(_ path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent("Sources/Glamor").appendingPathComponent(path), encoding: .utf8)
    }

    private let registry = PlaceRegistry(
        home: Place(id: "home", title: "Home", symbol: "house"),
        sections: [
            PlaceSection(id: "targets", title: "Targets", shortTitle: "Targets", symbol: "scope",
                         places: [Place(id: "host", title: "Host", symbol: "desktopcomputer")]),
            PlaceSection(id: "across", title: "Across types", shortTitle: "Across", symbol: "square.on.square",
                         places: [Place(id: "copy", title: "Copy", symbol: "doc.on.doc")]),
        ],
        settings: Place(id: "settings", title: "Settings", symbol: "gearshape"))

    // MARK: Sizes

    /// The one new token of v0.4.0: the rail is 72 wide, the column takes what is left of the 256 sidebar.
    @Test func theRailIs72WideAndTheColumnTakesTheRestOfTheSidebar() {
        #expect(G.Width.rail == 72)
        #expect(SidebarColumn<EmptyView>.width == 184)
        #expect(G.Width.rail + SidebarColumn<EmptyView>.width == G.Width.sidebar)
    }

    @Test func aRailItemIsAtLeast44HighAndTheMarkerIsTheTokenWidth() throws {
        #expect(G.Height.row52 >= 44, "a pointer target of 44 or more (the mock draws 52)")
        #expect(G.Row.markerWidth == 4, "3 fails check-sizes.sh; every marker is G.Row.markerWidth")
        #expect(SidebarRailItem.contentTop >= 0 && SidebarRailItem.contentHeight <= G.Height.row52, "the glyph and the title fit the 52")
    }

    // MARK: Title room

    // The rail's names, roles, the selected trait, the 44 point targets, the ground and the title's ink are proven in a real window
    // (scene `sidebar-b`, scripts/window/WindowCheck.swift); the tests here are the model and measured sizes, not greps for modifiers.

    /// The width of `title` in the rail's caption font, as the line is set (CoreText, no window).
    private func setWidth(_ title: String) -> CGFloat {
        let font = NSFont.systemFont(ofSize: GlamorTokens.Length.textXs)
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: title, attributes: [.font: font]))
        return CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
    }

    /// The short titles of the gallery in English and Indonesian, and the longest word a caller is likely to bring.
    /// "Pengaturan" (Settings) is the longest at 64.8 pt; "Targets" is 42.1 pt and was cut to "Targe…" when the room was 32.
    private let railTitles = ["Home", "Beranda", "Targets", "Target", "Across", "Own", "About", "Settings", "Pengaturan"]

    @Test func theTitleRoomIsTheButtonWidthWithNoPaddingOfItsOwn() {
        #expect(G.Width.rail - 2 * G.Row.cardInset == 64, "the button is 64 wide")
        #expect(SidebarRailItem.labelRoom == 64, "an item and its style add no horizontal padding: the title gets all 64")
    }

    @Test func everyRailTitleFitsItsRoomWithoutAnEllipsis() {
        for title in railTitles {
            let shown = setWidth(title) * G.Row.railTitleScale
            #expect(shown <= SidebarRailItem.labelRoom, "\(title) is \(shown) pt at the smallest scale, in \(SidebarRailItem.labelRoom) pt")
        }
    }

    /// The chosen marker is 4 wide, 4 in from the item's edge (x 4 to 8). A centred title wider than 48 pt would start under it
    /// ("Pengaturan" is 55.1 pt at the floor, so it starts at x 4.5), and 44 is all a title has with 10 reserved on each side: no
    /// readable scale fits "Pengaturan" there (44 / 64.8 = 0.68, under 8.2 pt). So the rail's marker sits beside the glyph: it is
    /// as tall as the glyph and starts where it starts, and ends 4 above the title, so no title can reach it at any width.
    @Test func theChosenMarkerSitsBesideTheGlyphAndEndsAboveTheTitle() {
        let markerLeft = G.Row.markerInset, markerRight = G.Row.markerInset + G.Row.markerWidth
        let glyphLeft = (SidebarRailItem.labelRoom - G.Icon.lg) / 2
        #expect(markerRight <= glyphLeft, "the marker (x \(markerLeft) to \(markerRight)) is left of the glyph (x \(glyphLeft))")
        let markerBottom = SidebarRailItem.contentTop + SidebarRailItem.markerHeight
        let titleTop = SidebarRailItem.contentTop + G.Icon.lg + G.Space.s4
        #expect(SidebarRailItem.markerHeight == G.Icon.lg, "the marker is the glyph's 20 tall, a sidebar row's 19.2 almost")
        #expect(markerBottom <= titleTop - G.Space.s4, "the marker ends at y \(markerBottom), the title starts at y \(titleTop)")
        #expect(SidebarRailItem.contentTop * 2 + SidebarRailItem.contentHeight == G.Height.row52, "the glyph and the title are centred in the 52")
    }

    @Test func theWidestTitleWouldHaveMetTheMarkerWhereItWasCentredAtItsFloor() {
        let left = (SidebarRailItem.labelRoom - setWidth("Pengaturan") * G.Row.railTitleScale) / 2
        #expect(left < G.Row.markerInset + G.Row.markerWidth, "the reason the marker moved: \(left) < 8")
    }

    // MARK: Areas

    @Test func theRailHasHomeThenEverySectionThenSettingsInOneOrder() {
        let areas = SidebarRailArea.all(in: registry)
        #expect(areas.map(\.id) == ["home", "targets", "across", "settings"])
    }

    @Test func aSectionIsNamedByItsShortTitleAndKeepsItsFullTitleAsTheTooltip() throws {
        let across = try #require(SidebarRailArea.all(in: registry).first { $0.id == "across" })
        #expect(across.name == "Across")
        #expect(across.help == "Across types")
        #expect(across.symbol == "square.on.square")
    }

    /// A tooltip is the button's AXHelp on macOS, so a tooltip equal to the name would be read twice. The rail has one only
    /// where it adds words: a section's full title. Home and Settings, and a section whose short title is its title, have none.
    @Test func aRailItemHasATooltipOnlyWhenItAddsWordsToTheName() throws {
        let areas = SidebarRailArea.all(in: registry)
        let across = try #require(areas.first { $0.id == "across" })
        #expect(across.tooltip == "Across types")
        for id in ["home", "targets", "settings"] {
            let area = try #require(areas.first { $0.id == id })
            #expect(area.tooltip == nil, "\(area.name): help equals the name, so there is no tooltip")
        }
    }

    @Test func homeAndSettingsAreNamedByTheirTitleAndHaveNoColumn() throws {
        let areas = SidebarRailArea.all(in: registry)
        let home = try #require(areas.first { $0.id == "home" })
        let settings = try #require(areas.last)
        #expect(home.name == "Home" && home.help == "Home" && home.symbol == "house")
        #expect(settings.name == "Settings" && settings.symbol == "gearshape")
        #expect(!home.hasColumn)
        #expect(!settings.hasColumn)
        #expect(areas.filter(\.hasColumn).map(\.id) == ["targets", "across"])
    }

    @Test func anEmptyRegistryStillHasHomeAndSettings() {
        let none = PlaceRegistry(home: registry.home, sections: [], settings: registry.settings)
        #expect(SidebarRailArea.all(in: none).map(\.id) == ["home", "settings"])
    }

    // MARK: Source shape

    /// On macOS a button's tooltip is its AXHelp, read after its name. The rail's tooltip sits on the hidden label, and the
    /// button after its style has none; the window check reads AXHelp of every rail item and fails when it is not empty.
    @Test func theRailButtonHasNoHelpOfItsOwnAndTheTooltipIsOnTheHiddenLabel() throws {
        let item = try source("macOS/SidebarRailItem.swift")
        let style = try #require(item.range(of: ".buttonStyle("))
        #expect(!item[style.upperBound...].contains(".help("), "a tooltip on the button is read a second time")
        let label = String(item[..<style.lowerBound])
        #expect(label.contains(".help(ifPresent: area.tooltip)") && label.contains(".accessibilityHidden(true)"))
    }

    /// The title starts where the rows' glyphs start: the list inset (8) and the row's padding (12), 20 from the column's edge.
    @Test func theColumnTitleStartsWhereTheRowGlyphsStart() throws {
        #expect(SidebarColumn<EmptyView>.titleInset == 20)
        #expect(SidebarColumn<EmptyView>.titleInset == G.Row.listInset + G.Row.padding)
    }

    @Test func theAreaBindingIsTheOnlyStateTheRailKeeps() throws {
        let rail = try source("macOS/SidebarRail.swift")
        #expect(rail.contains("@Binding var area: String"))
        #expect(!rail.contains("public let") && !rail.contains("public var area"), "the siblings keep their stored fields internal: only the init and the body are public")
        let column = try source("macOS/SidebarColumn.swift"), card = try source("macOS/ProfileCard.swift")
        #expect(!column.contains("public let") && !card.contains("public let"))
        #expect(!rail.contains("@State"))
        #expect(!rail.contains("@SceneStorage"))
    }
}
#endif
