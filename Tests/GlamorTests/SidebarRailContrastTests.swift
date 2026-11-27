#if os(macOS)
import SwiftUI
import Testing
@testable import Glamor

/// GL38: every colour pair the rail and the column draw, in light, dark and both with Increase contrast. Text holds
/// 4.5:1, a mark holds 3:1. The window check (scene `sidebar-b`) reads the same pairs from a capture.
@MainActor
struct SidebarRailContrastTests {
    private func holds(_ ink: Color, on ground: Color, _ need: Double, dark: Bool, high: Bool) {
        let r = ColorMeasure.ratio(ink, ground, dark: dark, high: high)
        #expect(r >= need, "ratio \(r) is under \(need) (dark \(dark), increased \(high))")
    }

    /// An unselected area: the glyph and the short title are `text2`, at rest, under the pointer and pressed.
    @Test(arguments: ColorMeasure.allModes) func anAreaLabelReadsOnTheWindowGroundUnderThePointerAndPressed(dark: Bool, high: Bool) {
        holds(G.text2, on: G.window, 4.5, dark: dark, high: high)
        holds(G.text2, on: G.Hover.onWindow, 4.5, dark: dark, high: high)
        holds(G.text2, on: G.Hover.pressed, 4.5, dark: dark, high: high)
    }

    /// The chosen area: `text` on the `panel` fill, with the marker 3:1 off that fill.
    @Test(arguments: ColorMeasure.allModes) func theChosenAreaReadsOnThePanelFillAndItsMarkerStandsOff(dark: Bool, high: Bool) {
        holds(G.text, on: G.panel, 4.5, dark: dark, high: high)
        holds(G.selectedMarker, on: G.panel, 3, dark: dark, high: high)
    }

    /// The column's title is `text` on the window ground.
    @Test(arguments: ColorMeasure.allModes) func theColumnTitleReadsOnTheWindowGround(dark: Bool, high: Bool) {
        holds(G.text, on: G.window, 4.5, dark: dark, high: high)
    }
}
#endif
