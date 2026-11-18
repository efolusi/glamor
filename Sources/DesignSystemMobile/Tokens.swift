import SwiftUI
import UIKit

// The design system's tokens (design/tokens.json) on iOS: the same colors and status meanings as the
// Mac. Sizes and navigation follow iOS (Platforms table: "Navigation and sizes from the iOS conventions").

extension Color {
    /// A color for light and dark, and, when `high` is given, its pair for Increase Contrast
    /// (design/README.md: `border` becomes `controlEdge`, `text3` becomes `text2`).
    static func adaptive(_ light: UInt32, _ dark: UInt32, high: (light: UInt32, dark: UInt32)? = nil) -> Color {
        Color(uiColor: UIColor { t in
            let pair = t.accessibilityContrast == .high ? (high ?? (light, dark)) : (light, dark)
            return UIColor(hex: t.userInterfaceStyle == .dark ? pair.1 : pair.0)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
    }
}

enum MK {
    static let window = Color.adaptive(0xF3F3F1, 0x0F1115)
    static let card = Color.adaptive(0xFFFFFF, 0x1D2028)
    static let subtle = Color.adaptive(0xF4F4F2, 0x20232C)
    static let border = Color.adaptive(0xE4E4E1, 0x2A2E39, high: (0x8C8C91, 0x6D717D))   // decorative; controlEdge with Increase Contrast
    static let controlEdge = Color.adaptive(0x8C8C91, 0x6D717D)   // a control's outline, 3:1 or more
    static let text = Color.adaptive(0x1C1C1E, 0xECEDF1)
    static let text2 = Color.adaptive(0x505056, 0xB3B7C4)
    static let text3 = Color.adaptive(0x6E6E75, 0x8A8E9C, high: (0x505056, 0xB3B7C4))   // text2 with Increase Contrast
    static let accent = Color.adaptive(0x1659FF, 0x6090FF, high: (0x074EFF, 0x6F9BFF))   // increased pair: 4.6:1 inside a 16% pill
    static let ok = Color.adaptive(0x247A43, 0x45C46A, high: (0x227440, 0x45C46A))
    static let warn = Color.adaptive(0xB24A00, 0xF2A445, high: (0xA84600, 0xF2A445))
    static let danger = Color.adaptive(0xCA282E, 0xF36368, high: (0xBD252B, 0xF47478))
    static let primary = Color.adaptive(0x1C1C1E, 0xECEDF1)
    static let onPrimary = Color.adaptive(0xFFFFFF, 0x111216)
    static let onAccent = Color.adaptive(0xFFFFFF, 0x111216)      // on an accent fill: 5.4:1 light, 6.2:1 dark
    static let avatar = Color(uiColor: UIColor(hex: 0x247A43))    // one solid fill in both themes, white initial 5.3:1
    static let pillOpacity: Double = 0.10                          // pill tint over card: every status color 4.6:1 or more
    static let pillOpacityHigh: Double = 0.16                      // pill and tile tints with Increase Contrast
    /// iPad: the widest a column of sentences gets (readable-width), centred.
    static let readableWidth: CGFloat = 672
    /// iPad split view: the Targets list column (PageiPad 360; 320 at Split View 2/3, PageiPadSizes).
    static let listColumn: CGFloat = 360
    static let listColumnNarrow: CGFloat = 320
    static let bannerOpacity: Double = 0.10                        // opacity-banner: a banner's tint over the card
    static let edgeOpacity: Double = 0.25                          // opacity-attention-stroke: a warn card's outline, as a banner's; the full color with Increase Contrast
    static let tintOpacity: Double = 0.12                          // opacity-tint: an icon tile's fill

    /// How strongly a tint shows for this contrast (`@Environment(\.colorSchemeContrast)`), as the Mac's
    /// K.Opacity.tint(_:) and .pill(_:): with Increase Contrast every tint is the 16% `pillOpacityHigh`.
    enum Tint {
        static func tile(_ contrast: ColorSchemeContrast) -> Double { contrast == .increased ? MK.pillOpacityHigh : MK.tintOpacity }
        static func pill(_ contrast: ColorSchemeContrast) -> Double { contrast == .increased ? MK.pillOpacityHigh : MK.pillOpacity }
        static func banner(_ contrast: ColorSchemeContrast) -> Double { contrast == .increased ? MK.pillOpacityHigh : MK.bannerOpacity }
    }

    /// Corner radii (radius-8, radius-12): code and chips, cards and bubbles.
    enum Radius {
        static let r8: CGFloat = 8
        static let r12: CGFloat = 12
    }

    /// The K-caret mark's colours, the same in both themes (logo-*).
    enum Logo {
        static let groundTop = Color(uiColor: UIColor(hex: 0x2E2F35))
        static let groundBottom = Color(uiColor: UIColor(hex: 0x161619))
        static let ink = Color(uiColor: UIColor(hex: 0xF4F5F7))
        static let cursor = Color(uiColor: UIColor(hex: 0x6090FF))
    }
    // Text: iOS text styles, so every size grows with the person's Dynamic Type setting, chosen so that at the
    // default setting each one is on the design system's scale: tokens ios-title, ios-headline, ios-body,
    // ios-small, ios-caption and ios-tiny (20 17 15 13 12 11). Touch targets are touch-44.
    static let title = Font.system(.title3, weight: .semibold)      // 20
    static let headline = Font.system(.headline)                     // 17 semibold
    static let body = Font.system(.subheadline)                      // 15
    static let bodyStrong = Font.system(.subheadline, weight: .semibold)
    static let small = Font.system(.footnote)                        // 13
    static let caption = Font.system(.caption)                       // 12
    static let captionStrong = Font.system(.caption, weight: .semibold)
    static let tiny = Font.system(.caption2)                         // 11
    static let icon = Font.system(.title3)                           // 20, a symbol in a 44-point target
    // Dynamic Type styles, so mono text grows with the person's text size (footnote is 13, caption 12 at default).
    static let mono = Font.system(.footnote, design: .monospaced)
    static let monoSmall = Font.system(.caption, design: .monospaced)
    static let monoTiny = Font.system(.caption2, design: .monospaced)
}
