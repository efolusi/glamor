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
        let item = try source("macOS/SidebarRailItem.swift")
        #expect(item.contains("SidebarItemStyle(isSelected: isSelected, height: G.Height.row52"))
        #expect(item.contains("horizontalPadding: 0"), "the title gets the whole 64 (see theTitleRoomIs...)")
        let style = try source("macOS/SidebarItemStyle.swift")
        #expect(style.contains(".selectedMarker(isSelected)"), "the rail draws the marker the item draws")
    }

    // MARK: Title room

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

    @Test func theRailSitsOnTheWindowGroundInAPlainStackAndKeepsTheTrafficLightsRoom() throws {
        let rail = try source("macOS/SidebarRail.swift")
        #expect(rail.contains(".background(G.window)"))
        #expect(rail.contains(".hoverGround(.window)"))
        #expect(rail.contains("G.Width.rail"))
        #expect(rail.contains("G.Height.trafficLights"))
        #expect(rail.contains("WindowDragArea()"))
        #expect(!rail.contains("LazyVStack"), "every area must stay in the accessibility tree and the Tab order")
        #expect(rail.contains("footer"))
    }

    @Test func theRailAndTheColumnAreEachOneNamedElement() throws {
        let rail = try source("macOS/SidebarRail.swift")
        #expect(rail.contains("GlamorText.string(.sidebarLabel)"))
        #expect(rail.contains(".accessibilityElement(children: .contain)"))
        let column = try source("macOS/SidebarColumn.swift")
        #expect(column.contains(".accessibilityElement(children: .contain)"))
        #expect(column.contains(".accessibilityLabel(title)"), "the column is named by its title, so VoiceOver does not say Sidebar twice")
    }

    @Test func aRailItemIsOneButtonWithTheGlyphOverTheShortTitle() throws {
        let item = try source("macOS/SidebarRailItem.swift")
        #expect(item.contains("Button(action: action)"))
        #expect(item.contains("G.Icon.lg"))
        #expect(item.contains(".textStyle(.caption)"))
        #expect(item.contains(".accessibilityLabel(area.name)"))
        #expect(!item.contains(".help(area.help)"), "the button has no help of its own: a tooltip equal to the name is read twice")
        #expect(item.contains(".help(ifPresent: area.tooltip)"))
        #expect(item.contains(".accessibilityAddTraits(isSelected ? .isSelected : [])"))
        #expect(item.contains(".foregroundStyle(isSelected ? G.text : G.text2)"))
    }

    @Test func theColumnTitleIsTitleSAndAHeaderAndTheRowsScrollInAPlainStack() throws {
        let column = try source("macOS/SidebarColumn.swift")
        #expect(column.contains(".textStyle(.titleS)"))
        #expect(column.contains(".accessibilityAddTraits(.isHeader)"))
        #expect(column.contains("G.Width.sidebar - G.Width.rail"))
        #expect(column.contains("ScrollView"))
        #expect(!column.contains("LazyVStack"))
        #expect(column.contains(".background(G.window)"))
    }

    @Test func theAreaBindingIsTheOnlyStateTheRailKeeps() throws {
        let rail = try source("macOS/SidebarRail.swift")
        #expect(rail.contains("@Binding public var area: String"))
        #expect(!rail.contains("@State"))
        #expect(!rail.contains("@SceneStorage"))
    }
}
#endif
