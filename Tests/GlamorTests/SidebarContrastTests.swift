#if os(macOS)
import SwiftUI
import Testing
@testable import Glamor

/// GL32 to GL34: every colour pair the sidebar draws, in light, dark and both with Increase contrast. Text holds
/// 4.5:1, a mark or an edge holds 3:1. The window check (scene `sidebar-a`) reads the same pairs from a capture.
@MainActor
struct SidebarContrastTests {
    private func holds(_ ink: Color, on ground: Color, _ need: Double, dark: Bool, high: Bool) {
        let r = ColorMeasure.ratio(ink, ground, dark: dark, high: high)
        #expect(r >= need, "ratio \(r) is under \(need) (dark \(dark), increased \(high))")
    }

    @Test(arguments: ColorMeasure.allModes) func aRowNameReadsOnTheWindowGroundAndUnderThePointer(dark: Bool, high: Bool) {
        holds(G.text2, on: G.window, 4.5, dark: dark, high: high)
        holds(G.text2, on: G.Hover.onWindow, 4.5, dark: dark, high: high)
        holds(G.text, on: G.Hover.onWindow, 4.5, dark: dark, high: high)
        holds(G.text, on: G.Hover.pressed, 4.5, dark: dark, high: high)
    }

    @Test(arguments: ColorMeasure.allModes) func theSelectedRowNameReadsOnThePanelFill(dark: Bool, high: Bool) {
        holds(G.text, on: G.panel, 4.5, dark: dark, high: high)
    }

    @Test(arguments: ColorMeasure.allModes) func theSelectedMarkerStandsThreeToOneOffThePanelFill(dark: Bool, high: Bool) {
        holds(G.selectedMarker, on: G.panel, 3, dark: dark, high: high)
    }

    /// A folded section that holds the chosen place shows the marker colour as a dot on its header, on the window ground.
    @Test(arguments: ColorMeasure.allModes) func theFoldedHeadersDotStandsThreeToOneOffTheWindowGround(dark: Bool, high: Bool) {
        holds(G.selectedMarker, on: G.window, 3, dark: dark, high: high)
        holds(G.selectedMarker, on: G.Hover.onWindow, 3, dark: dark, high: high)
    }

    @Test(arguments: ColorMeasure.allModes) func aCountReadsOnItsPill(dark: Bool, high: Bool) {
        holds(G.accentFg, on: G.accentSubtle, 4.5, dark: dark, high: high)
    }

    @Test(arguments: ColorMeasure.allModes) func aSectionTitleReadsOnTheWindowGround(dark: Bool, high: Bool) {
        holds(G.text3, on: G.window, 4.5, dark: dark, high: high)
        holds(G.text3, on: G.Hover.onWindow, 4.5, dark: dark, high: high)
    }

    @Test(arguments: ColorMeasure.allModes) func theSearchLabelAndGlyphReadOnTheFieldFill(dark: Bool, high: Bool) {
        holds(G.placeholder, on: G.field, 4.5, dark: dark, high: high)
        holds(G.text3, on: G.field, 4.5, dark: dark, high: high)
    }

    /// Under the pointer and pressed the search label turns `text2`; it must read on the fill it then sits on.
    @Test(arguments: ColorMeasure.allModes) func theSearchLabelReadsUnderThePointerAndPressed(dark: Bool, high: Bool) {
        holds(G.text2, on: G.field, 4.5, dark: dark, high: high)
        holds(G.text2, on: G.Hover.pressed, 4.5, dark: dark, high: high)
    }

    @Test(arguments: ColorMeasure.allModes) func theUnfocusedSearchEdgeStandsThreeToOneOffTheWindowGround(dark: Bool, high: Bool) {
        holds(G.controlEdge, on: G.window, 3, dark: dark, high: high)
    }
}
#endif
