#if os(macOS)
import AppKit
import Glamor
import SwiftUI
import Testing

/// The contrast claims in tokens.json, measured on the resolved colors in light and dark.
@MainActor
struct ContrastTests {
    private func rgb(_ color: Color, dark: Bool) -> (Double, Double, Double) {
        var out = (0.0, 0.0, 0.0)
        NSAppearance(named: dark ? .darkAqua : .aqua)!.performAsCurrentDrawingAppearance {
            let c = NSColor(color).usingColorSpace(.sRGB)!
            out = (Double(c.redComponent), Double(c.greenComponent), Double(c.blueComponent))
        }
        return out
    }

    private func luminance(_ c: (Double, Double, Double)) -> Double {
        func lin(_ v: Double) -> Double { v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
        return 0.2126 * lin(c.0) + 0.7152 * lin(c.1) + 0.0722 * lin(c.2)
    }

    private func ratio(_ a: Color, _ b: Color, dark: Bool) -> Double {
        let x = luminance(rgb(a, dark: dark)), y = luminance(rgb(b, dark: dark))
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
    /// (light: white 5.24, dark ink 3.30; dark: white 2.05, dark ink 8.43), and that one holds 4.5:1.
    @Test(arguments: [false, true]) func theMainActionLabelIsTheBetterOfWhiteAndInkAndHolds4Point5(dark: Bool) {
        let white = Color(.sRGB, red: 1, green: 1, blue: 1)
        let ink = Color(.sRGB, red: 0.1176, green: 0.102, blue: 0.0784)
        let best = max(ratio(white, G.accent, dark: dark), ratio(ink, G.accent, dark: dark))
        #expect(ratio(G.onAccent, G.accent, dark: dark) >= 4.5)
        #expect(abs(ratio(G.onAccent, G.accent, dark: dark) - best) < 0.01, "dark=\(dark)")
    }

    @Test(arguments: [false, true]) func statusColorsReadAsTextOnACard(dark: Bool) {
        for status in [G.accent, G.ok, G.warn, G.danger] {
            #expect(ratio(status, G.card, dark: dark) >= 4.5)
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
        for tone in [G.accent, G.ok, G.warn, G.danger] {
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
