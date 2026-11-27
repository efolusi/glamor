#if os(macOS)
import Foundation
import SwiftUI
import Testing
@testable import Glamor

/// GL31: the `Sidebar` container. What it draws is proven in a real window (scripts/check-window.sh, scene
/// `sidebar-a`); these pin the source shape that the window check relies on, and the words it speaks.
@MainActor
struct SidebarContainerTests {
    private func source(_ path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent("Sources/Glamor").appendingPathComponent(path), encoding: .utf8)
    }

    @Test func theSidebarSitsOnTheWindowGroundAndHoversOnIt() throws {
        let text = try source("macOS/Sidebar.swift")
        #expect(text.contains(".background(G.window)"))
        #expect(text.contains(".hoverGround(.window)"))
    }

    @Test func theEdgeIsTheExistingDividerWithNoLineAndHidesTheSidebarWhenDraggedUnderTheSmallest() throws {
        let text = try source("macOS/Sidebar.swift")
        #expect(text.contains("SplitDivider("))
        #expect(text.contains("area: G.Resize.sidebar"))
        #expect(text.contains("hairline: false"))
        #expect(text.contains("onCollapse: onHide"))
    }

    /// A LazyVStack leaves the rows below the fold out of the accessibility tree and out of the Tab order until they are
    /// scrolled to; the window check walks all of them. A sidebar has about 25 rows, so a plain stack is cheap.
    @Test func theRowsAreInAPlainStackInsideTheScrollView() throws {
        let text = try source("macOS/Sidebar.swift")
        #expect(text.contains("ScrollView"))
        #expect(!text.contains("LazyVStack"), "rows below the fold must stay in the accessibility tree")
        #expect(!text.contains("SideListStack"), "SideListStack is a LazyVStack")
    }

    @Test func theTopRowDragsTheWindowAndKeepsTheTrafficLightsRoom() throws {
        let text = try source("macOS/Sidebar.swift")
        #expect(text.contains("WindowDragArea()"))
        #expect(text.contains("G.Height.trafficLights"))
    }

    /// The first version is solid: no glass, so no availability gate and no R-10 question.
    @Test func theSidebarDrawsNoGlass() throws {
        let text = try source("macOS/Sidebar.swift")
        #expect(!text.contains("glass"))
        #expect(!text.contains("Material"))
    }

    @Test func theFooterIsPinnedBelowAHairlineAndTheContentScrolls() throws {
        let text = try source("macOS/Sidebar.swift")
        let scroll = try #require(text.range(of: "ScrollView"))
        let line = try #require(text.range(of: "Hairline()"))
        #expect(scroll.lowerBound < line.lowerBound, "the scroll area comes before the rule above the footer")
    }

    @Test func theContainerIsOneNamedElementAndTheHideButtonIsNamed() throws {
        let text = try source("macOS/Sidebar.swift")
        #expect(text.contains(".accessibilityElement(children: .contain)"))
        #expect(text.contains("GlamorText.string(.sidebarLabel)"))
        #expect(text.contains("GlamorText.string(.sidebarHide)"))
        #expect(text.contains("GlamorText.string(.sidebarWidth)"))
    }

    @Test func theWordsAreInBothLanguages() {
        #expect(GlamorText.string(.sidebarLabel, language: "en") == "Sidebar")
        #expect(GlamorText.string(.sidebarLabel, language: "id") == "Bilah samping")
        #expect(GlamorText.string(.sidebarHide, language: "en") == "Hide sidebar")
        #expect(GlamorText.string(.sidebarHide, language: "id") == "Sembunyikan bilah samping")
        #expect(GlamorText.string(.sidebarWidth, language: "en") == "Sidebar width")
        #expect(GlamorText.string(.sidebarWidth, language: "id") == "Lebar bilah samping")
    }

    @Test func aSidebarIsResizableUnlessTheCallerSaysOtherwise() {
        var width: CGFloat = G.Resize.sidebar.ideal ?? 0
        let binding = Binding(get: { width }, set: { width = $0 })
        let resizable = Sidebar(width: binding, onHide: {}) { EmptyView() } content: { EmptyView() } footer: { EmptyView() }
        #expect(resizable.isResizable)
        let fixed = Sidebar(width: binding, isResizable: false, onHide: {}) { EmptyView() } content: { EmptyView() } footer: { EmptyView() }
        #expect(!fixed.isResizable)
    }
}
#endif
