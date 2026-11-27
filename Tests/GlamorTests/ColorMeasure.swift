#if os(macOS)
import AppKit
import SwiftUI

/// A colour as the screen shows it in one of the four modes, and the WCAG contrast between two of them.
/// `ContrastTests` keeps private copies of the same arithmetic; the sidebar tests share this one.
enum ColorMeasure {
    /// Light, dark, light with Increase contrast, dark with Increase contrast: (dark, high).
    static let allModes = [(false, false), (true, false), (false, true), (true, true)]

    static func rgb(_ color: Color, dark: Bool, high: Bool) -> (Double, Double, Double) {
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

    static func luminance(_ c: (Double, Double, Double)) -> Double {
        func lin(_ v: Double) -> Double { v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
        return 0.2126 * lin(c.0) + 0.7152 * lin(c.1) + 0.0722 * lin(c.2)
    }

    static func ratio(_ a: Color, _ b: Color, dark: Bool, high: Bool) -> Double {
        let x = luminance(rgb(a, dark: dark, high: high)), y = luminance(rgb(b, dark: dark, high: high))
        return (max(x, y) + 0.05) / (min(x, y) + 0.05)
    }
}
#endif
