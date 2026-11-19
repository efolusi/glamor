#if os(iOS)
import Glamor
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
}
#endif
