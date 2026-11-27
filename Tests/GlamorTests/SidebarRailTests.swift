#if os(macOS)
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
        let style = try source("macOS/SidebarItemStyle.swift")
        #expect(style.contains(".selectedMarker(isSelected)"), "the rail draws the marker the item draws")
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
        #expect(item.contains(".help(area.help)"))
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
