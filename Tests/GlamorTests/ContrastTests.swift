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

    @Test(arguments: [false, true]) func statusColorsReadAsTextOnACard(dark: Bool) {
        for status in [G.accent, G.ok, G.warn, G.danger] {
            #expect(ratio(status, G.card, dark: dark) >= 4.5)
        }
    }

    @Test(arguments: [false, true]) func controlEdgesAndButtonLabelsHoldTheirRatio(dark: Bool) {
        #expect(ratio(G.controlEdge, G.card, dark: dark) >= 3)
        #expect(ratio(G.onPrimary, G.primary, dark: dark) >= 4.5)
        #expect(ratio(G.onAccent, G.accent, dark: dark) >= 4.5)
    }
}
#endif
