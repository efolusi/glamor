#if os(macOS)
import AppKit
@testable import Glamor
import SwiftUI
import Testing

/// The contrast claims in tokens.json, measured on the resolved colors in light and dark.
@MainActor
struct ContrastTests {
    /// Light, dark, light with Increase contrast, dark with Increase contrast: (dark, high).
    static let allModes = [(false, false), (true, false), (false, true), (true, true)]

    private func rgb(_ color: Color, dark: Bool, high: Bool = false) -> (Double, Double, Double) {
        var out = (0.0, 0.0, 0.0)
        let name: NSAppearance.Name = switch (dark, high) {
        case (false, false): .aqua
        case (true, false): .darkAqua
        case (false, true): .accessibilityHighContrastAqua
        case (true, true): .accessibilityHighContrastDarkAqua
        }
        NSAppearance(named: name)!.performAsCurrentDrawingAppearance {
            let c = NSColor(color).usingColorSpace(.sRGB)!
            out = (Double(c.redComponent), Double(c.greenComponent), Double(c.blueComponent))
        }
        return out
    }

    private func luminance(_ c: (Double, Double, Double)) -> Double {
        func lin(_ v: Double) -> Double { v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
        return 0.2126 * lin(c.0) + 0.7152 * lin(c.1) + 0.0722 * lin(c.2)
    }

    private func ratio(_ a: Color, _ b: Color, dark: Bool, high: Bool = false) -> Double {
        let x = luminance(rgb(a, dark: dark, high: high)), y = luminance(rgb(b, dark: dark, high: high))
        return (max(x, y) + 0.05) / (min(x, y) + 0.05)
    }

    @Test func lightAndDarkResolveToDifferentColors() {
        #expect(luminance(rgb(G.window, dark: false)) > 0.8)
        #expect(luminance(rgb(G.window, dark: true)) < 0.05)
    }

    @Test(arguments: [false, true]) func textReadsOnEverySurface(dark: Bool) {
        for surface in [G.window, G.panel, G.card, G.subtle, G.cardHover] {
            #expect(ratio(G.text, surface, dark: dark) >= 12)
            #expect(ratio(G.text2, surface, dark: dark) >= 7)
            #expect(ratio(G.text3, surface, dark: dark) >= 4.5)
        }
    }

    /// GL18: a search field's placeholder is text, so it holds 4.5:1 on every surface a field sits on (the
    /// darkest of them included), light and dark. The system's own placeholder colour measured far below.
    @Test(arguments: [false, true]) func thePlaceholderReadsOnEverySurfaceAFieldSitsOn(dark: Bool) {
        for surface in [G.window, G.panel, G.card, G.subtle, G.cardHover, G.field] {
            #expect(ratio(G.placeholder, surface, dark: dark) >= 4.5, "dark=\(dark)")
        }
    }

    /// GL18: on glass the field's ground is the material tint at the clear material's opacity over the surface.
    @Test(arguments: [false, true]) func thePlaceholderReadsOnGlassOverEverySurface(dark: Bool) {
        typealias C = GlamorTokens.Color
        func pick(_ p: GlamorTokens.ColorPair) -> GlamorTokens.RGBA { dark ? p.dark : p.light }
        let tint = pick(C.materialTint)
        let a = GlamorTokens.Number.materialClear
        let ink = luminance(rgb(G.placeholder, dark: dark))
        for ground in [C.surfacePage, C.surfaceCard, C.surfacePanel, C.surfaceSubtle, C.surfaceSunken].map(pick) {
            let glass = luminance((tint.red * a + ground.red * (1 - a), tint.green * a + ground.green * (1 - a),
                                   tint.blue * a + ground.blue * (1 - a)))
            let value = (max(glass, ink) + 0.05) / (min(glass, ink) + 0.05)
            #expect(value >= 4.5, "dark=\(dark) ratio=\(value)")
        }
    }

    /// GL19: the label on the main action's fill is whichever of white and the dark ink reads better on it
    /// (copper, both themes: white 2.72, dark ink 6.37), and that one holds 4.5:1, with Increase contrast too.
    @Test(arguments: ContrastTests.allModes) func theMainActionLabelIsTheBetterOfWhiteAndInkAndHolds4Point5(dark: Bool, high: Bool) {
        let white = Color(.sRGB, red: 1, green: 1, blue: 1)
        let ink = Color(.sRGB, red: 0.1176, green: 0.102, blue: 0.0784)
        let best = max(ratio(white, G.accent, dark: dark, high: high), ratio(ink, G.accent, dark: dark, high: high))
        #expect(ratio(G.onAccent, G.accent, dark: dark, high: high) >= 4.5)
        #expect(abs(ratio(G.onAccent, G.accent, dark: dark, high: high) - best) < 0.01, "dark=\(dark) high=\(high)")
    }

    /// GL26: the label also reads on the main action's hover and pressed fills, in every mode (the vendored tokens
    /// have no Increase contrast value for these, so all four modes resolve alike): ink on `accentHover` 8.01,
    /// on `accentPressed` 5.28.
    @Test(arguments: ContrastTests.allModes) func theMainActionLabelHoldsFourPointFiveOnHoverAndPressed(dark: Bool, high: Bool) {
        for fill in [G.accentHover, G.accentPressed] {
            #expect(ratio(G.onAccent, fill, dark: dark, high: high) >= 4.5, "dark=\(dark) high=\(high)")
        }
    }

    /// GL26: the accent is not text (copper on a card is 2.72:1 in light). Accent as text is the link colour,
    /// so the status list reads `G.link` where it read `G.accent`; all four hold 4.5:1 on a card in every mode.
    @Test(arguments: ContrastTests.allModes) func statusColorsReadAsTextOnACard(dark: Bool, high: Bool) {
        for status in [G.link, G.ok, G.warn, G.danger] {
            #expect(ratio(status, G.card, dark: dark, high: high) >= 4.5, "dark=\(dark) high=\(high)")
        }
    }

    /// GL26: the link colour, the accent as text, reads 4.5:1 on every ground a link sits on, and inside the
    /// accent tint, in light, dark and both Increase contrast modes.
    @Test(arguments: ContrastTests.allModes) func theLinkColourReadsOnEveryGroundALinkSitsOn(dark: Bool, high: Bool) {
        for ground in [G.window, G.panel, G.card, G.subtle, G.cardHover, G.field, G.accentSubtle] {
            #expect(ratio(G.link, ground, dark: dark, high: high) >= 4.5, "dark=\(dark) high=\(high)")
        }
    }

    /// GL26: the accent as a shape (the main button's rim, a progress fill, a checked mark) is `accentEdge`, and it
    /// holds 3:1 (WCAG 1.4.11) against the page, a card, a sunken well, a track and the border colour, in light,
    /// dark, and both Increase contrast modes. Plain `G.accent` does not: 2.12 to 2.72 on those in light.
    @Test(arguments: ContrastTests.allModes) func theAccentAsAShapeHoldsThreeToOneOnEveryGround(dark: Bool, high: Bool) {
        let track = Color(GlamorTokens.Color.surfaceTrack)
        for ground in [G.window, G.card, G.subtle, track, G.border] {
            #expect(ratio(G.accentEdge, ground, dark: dark, high: high) >= 3, "dark=\(dark) high=\(high)")
        }
    }

    /// GL27: the switch's on state is the track of the system `Toggle`, tinted `accentEdge`. It holds 3:1 against the card
    /// the switch sits on (light, dark, both Increase contrast modes) and against the page and a sunken well.
    @Test(arguments: ContrastTests.allModes) func theSwitchOnStateHoldsThreeToOneOnTheCard(dark: Bool, high: Bool) {
        for ground in [G.card, G.window, G.subtle] {
            #expect(ratio(G.accentEdge, ground, dark: dark, high: high) >= 3, "dark=\(dark) high=\(high)")
        }
    }

    /// GL26: a progress bar's default fill is `accentEdge` and holds 3:1 on its track (`border`) in every mode.
    @Test(arguments: ContrastTests.allModes) func theProgressBarDefaultFillHoldsThreeToOneOnItsTrack(dark: Bool, high: Bool) {
        #expect(ratio(ProgressBar(value: 0.5).tone, G.border, dark: dark, high: high) >= 3, "dark=\(dark) high=\(high)")
    }

    /// GL28: every ProgressBar tone (the default `accentEdge` and `ok`, `warn`, `danger`) holds 3:1 on the track the
    /// bar draws (`surfaceTrack`), in light, dark and both Increase contrast modes. On `border`, the old track, the
    /// status tones were 1.65 to 1.94:1 in light and dark Increase contrast, because `border` turns mid-tone there.
    @Test(arguments: ContrastTests.allModes) func everyProgressBarToneHoldsThreeToOneOnItsTrack(dark: Bool, high: Bool) {
        let track = Color(GlamorTokens.Color.surfaceTrack)
        for (name, tone) in [("default", ProgressBar(value: 0).tone), ("ok", G.ok), ("warn", G.warn), ("danger", G.danger)] {
            #expect(ratio(tone, track, dark: dark, high: high) >= 3, "\(name) dark=\(dark) high=\(high)")
        }
    }

    /// GL28: a disabled main action has its own label colour. Its fill is the accent at 30% over the ground, and the
    /// ink (`onAccent`) on that was 1.67 to 1.83:1 in dark. `text3` reads 3.5:1 or more in every mode and beats the
    /// ink wherever the ink falls short (disabled controls are exempt from WCAG 1.4.3; 3:1 is the floor kept here).
    @Test(arguments: ContrastTests.allModes) func theDisabledMainActionLabelReadsOnItsFill(dark: Bool, high: Bool) {
        for ground in [G.window, G.panel, G.card, G.subtle] {
            let g = rgb(ground, dark: dark, high: high), a = rgb(G.accent, dark: dark, high: high)
            let fill = (a.0 * G.Opacity.disabled + g.0 * (1 - G.Opacity.disabled),
                        a.1 * G.Opacity.disabled + g.1 * (1 - G.Opacity.disabled),
                        a.2 * G.Opacity.disabled + g.2 * (1 - G.Opacity.disabled))
            func against(_ c: Color) -> Double {
                let x = luminance(rgb(c, dark: dark, high: high)), y = luminance(fill)
                return (max(x, y) + 0.05) / (min(x, y) + 0.05)
            }
            #expect(against(G.text3) >= 3, "text3 dark=\(dark) high=\(high) ratio=\(against(G.text3))")
            if against(G.onAccent) < 3 { #expect(against(G.text3) > against(G.onAccent), "dark=\(dark) high=\(high)") }
        }
    }

    /// GL36: the words of the Pro and Soon marks are text: 4.5:1 on every ground a mark sits on (inside pages: the
    /// page, a panel, a card, a subtle well, a hovered card), in light, dark and both Increase contrast modes.
    @Test(arguments: ContrastTests.allModes) func theProAndSoonLabelsReadOnEveryGroundAMarkSitsOn(dark: Bool, high: Bool) {
        for mark in PlanMark.allCases {
            for ground in [G.window, G.panel, G.card, G.subtle, G.cardHover] {
                #expect(ratio(mark.label, ground, dark: dark, high: high) >= 4.5, "\(mark) dark=\(dark) high=\(high)")
            }
        }
    }

    /// GL36: the Pro outline is a shape, so it is `accentEdge`: 3:1 against the page, a card and a subtle well in every
    /// mode. The Soon outline is dashed in the border colour, 1.10 to 1.40:1: nearly invisible, and that is fine,
    /// because the word carries the meaning, not the outline. It has no 3:1 claim; the Soon word has 4.5:1 above.
    @Test(arguments: ContrastTests.allModes) func theProOutlineHoldsThreeToOneOnEveryGroundAMarkSitsOn(dark: Bool, high: Bool) {
        for ground in [G.window, G.card, G.subtle] {
            #expect(ratio(PlanMark.pro.edge, ground, dark: dark, high: high) >= 3, "dark=\(dark) high=\(high)")
        }
    }

    @Test(arguments: [false, true]) func controlEdgesAndButtonLabelsHoldTheirRatio(dark: Bool) {
        #expect(ratio(G.controlEdge, G.card, dark: dark) >= 3)
        #expect(ratio(G.onAccent, G.accent, dark: dark) >= 4.5)
        // A selected row's fill shows against the card and panel it sits on; the marker carries the meaning.
        for ground in [G.card, G.panel] {
            #expect(ratio(G.accentSubtle, ground, dark: dark) >= 1.05)
        }
        // A ProgressBar's fill against its track (non-text, 3:1), for the default tone and every status tone.
        // (The default tone in every mode: theAccentAsAShapeHoldsThreeToOneOnEveryGround.)
        for tone in [ProgressBar(value: 0).tone, G.ok, G.warn, G.danger] {
            #expect(ratio(tone, G.border, dark: dark) >= 3)
        }
        // The brand's brown marks: focus ring, selected marker and tile glyphs, 3:1 or more on every surface.
        for surface in [G.window, G.panel, G.card, G.subtle, G.cardHover, G.accentSubtle] {
            #expect(ratio(G.focus, surface, dark: dark) >= 3)
            #expect(ratio(G.selectedMarker, surface, dark: dark) >= 3)
            #expect(ratio(G.accentFg, surface, dark: dark) >= 3)
        }
    }
}
#endif
