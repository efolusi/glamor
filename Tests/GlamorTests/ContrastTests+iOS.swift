#if os(iOS)
@testable import Glamor
import SwiftUI
import Testing
import UIKit

/// The iOS twin of ContrastTests: the same pairs, resolved through UIKit traits in light, dark and
/// Increase Contrast.
@MainActor
struct ContrastTestsIOS {
    private func rgb(_ color: Color, dark: Bool, high: Bool) -> (Double, Double, Double) {
        let traits = UITraitCollection { t in
            t.userInterfaceStyle = dark ? .dark : .light
            t.accessibilityContrast = high ? .high : .normal
        }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).resolvedColor(with: traits).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b))
    }

    private func luminance(_ c: (Double, Double, Double)) -> Double {
        func lin(_ v: Double) -> Double { v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
        return 0.2126 * lin(c.0) + 0.7152 * lin(c.1) + 0.0722 * lin(c.2)
    }

    private func ratio(_ a: Color, _ b: Color, dark: Bool, high: Bool) -> Double {
        let x = luminance(rgb(a, dark: dark, high: high)), y = luminance(rgb(b, dark: dark, high: high))
        return (max(x, y) + 0.05) / (min(x, y) + 0.05)
    }

    @Test(arguments: [(false, false), (true, false), (false, true), (true, true)])
    func textAndMarksReadOnEverySurface(dark: Bool, high: Bool) {
        for surface in [G.window, G.card, G.subtle] {
            #expect(ratio(G.text, surface, dark: dark, high: high) >= 12)
            #expect(ratio(G.text2, surface, dark: dark, high: high) >= 7)
            #expect(ratio(G.text3, surface, dark: dark, high: high) >= 4.5)
            #expect(ratio(G.accentFg, surface, dark: dark, high: high) >= 3)
            #expect(ratio(G.controlEdge, surface, dark: dark, high: high) >= 3)
        }
        for status in [G.ok, G.warn, G.danger] {
            #expect(ratio(status, G.card, dark: dark, high: high) >= 4.5)
        }
        #expect(ratio(G.onAccent, G.accent, dark: dark, high: high) >= 4.5)
        #expect(ratio(G.onAvatar, G.avatar, dark: dark, high: high) >= 4.5)
    }

    /// GL36: the Pro and Soon words are text: 4.5:1 on every ground a mark sits on, in every mode; the Pro outline is a
    /// shape, `accentEdge`, 3:1 on the page, a card and a subtle well. The Soon outline is a dashed hairline carried by
    /// its word and its dash, so it has no 3:1 claim.
    @Test(arguments: [(false, false), (true, false), (false, true), (true, true)])
    func theProAndSoonMarksReadOnEveryGroundAMarkSitsOn(dark: Bool, high: Bool) {
        for mark in PlanMark.allCases {
            for ground in [G.window, G.card, G.subtle] {
                #expect(ratio(mark.label, ground, dark: dark, high: high) >= 4.5, "\(mark) dark=\(dark) high=\(high)")
            }
        }
        for ground in [G.window, G.card, G.subtle] {
            #expect(ratio(PlanMark.pro.edge, ground, dark: dark, high: high) >= 3, "dark=\(dark) high=\(high)")
        }
    }

    /// GL26: the accent as a shape is `accentEdge`: 3:1 against the page, a card, a sunken well, a track and the
    /// border colour in light, dark and both Increase Contrast modes (plain `G.accent` is 2.12 to 2.72 in light).
    @Test(arguments: [(false, false), (true, false), (false, true), (true, true)])
    func theAccentAsAShapeHoldsThreeToOneOnEveryGround(dark: Bool, high: Bool) {
        let track = Color(GlamorTokens.Color.surfaceTrack)
        for ground in [G.window, G.card, G.subtle, track, G.border] {
            #expect(ratio(G.accentEdge, ground, dark: dark, high: high) >= 3, "dark=\(dark) high=\(high)")
        }
    }

    private func holds(_ ink: Color, on ground: Color, _ need: Double, dark: Bool, high: Bool) {
        let r = ratio(ink, ground, dark: dark, high: high)
        #expect(r >= need, "ratio \(r) is under \(need) (dark \(dark), increased \(high))")
    }

    /// GL39: every pair the iOS sidebar row draws, as `SidebarContrastTests` holds them on the Mac. The row sits on the
    /// window ground; the chosen row on the panel fill; a press takes `G.Hover.pressed`.
    @Test(arguments: [(false, false), (true, false), (false, true), (true, true)])
    func theSidebarRowReadsOnEveryFillItSitsOn(dark: Bool, high: Bool) {
        holds(G.text2, on: G.window, 4.5, dark: dark, high: high)
        holds(G.text2, on: G.Hover.pressed, 4.5, dark: dark, high: high)
        holds(G.text, on: G.Hover.pressed, 4.5, dark: dark, high: high)
        holds(G.text, on: G.panel, 4.5, dark: dark, high: high)
        holds(G.selectedMarker, on: G.panel, 3, dark: dark, high: high)
        holds(G.accentFg, on: G.accentSubtle, 4.5, dark: dark, high: high)
        holds(G.text3, on: G.window, 4.5, dark: dark, high: high)
    }

    @Test(arguments: [(false, false), (true, false), (false, true), (true, true)])
    func theSidebarSearchReadsOnTheFieldFill(dark: Bool, high: Bool) {
        holds(G.placeholder, on: G.field, 4.5, dark: dark, high: high)
        holds(G.text3, on: G.field, 4.5, dark: dark, high: high)
        holds(G.controlEdge, on: G.window, 3, dark: dark, high: high)
    }
}
#endif
