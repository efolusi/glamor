#if os(iOS)
import SwiftUI
import UIKit

// The design system's tokens (design/tokens.json) on iOS: the same colors and status meanings as the
// Mac. Sizes and navigation follow iOS (Platforms table: "Navigation and sizes from the iOS conventions").

public extension Color {
    /// A color for light and dark, and, when `increased` is given, its pair for Increase Contrast
    /// (design/README.md: `border` becomes `controlEdge`, `text3` becomes `text2`).
    static func adaptive(_ light: UInt32, _ dark: UInt32, increased: (light: UInt32, dark: UInt32)? = nil) -> Color {
        Color(uiColor: UIColor { t in
            let pair = t.accessibilityContrast == .high ? (increased ?? (light, dark)) : (light, dark)
            return UIColor(hex: t.userInterfaceStyle == .dark ? pair.1 : pair.0)
        })
    }
}

public extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
    }
}

public enum G {
    public static let window = Color.adaptive(0xF3F3F1, 0x0F1115)
    public static let card = Color.adaptive(0xFFFFFF, 0x1D2028)
    public static let subtle = Color.adaptive(0xF4F4F2, 0x20232C)
    public static let border = Color.adaptive(0xE4E4E1, 0x2A2E39, increased: (0x8C8C91, 0x6D717D))   // decorative; controlEdge with Increase Contrast
    public static let controlEdge = Color.adaptive(0x8C8C91, 0x6D717D)   // a control's outline, 3:1 or more
    public static let text = Color.adaptive(0x1C1C1E, 0xECEDF1)
    public static let text2 = Color.adaptive(0x505056, 0xB3B7C4)
    public static let text3 = Color.adaptive(0x69696F, 0x9296A4, increased: (0x505056, 0xB3B7C4))   // text2 with Increase Contrast
    public static let accent = Color.adaptive(0x1659FF, 0x6292FF, increased: (0x074EFF, 0x6F9BFF))   // increased pair: 4.6:1 inside a 16% pill
    public static let ok = Color.adaptive(0x247A43, 0x45C46A, increased: (0x227440, 0x45C46A))
    public static let warn = Color.adaptive(0xB24A00, 0xF2A445, increased: (0xA84600, 0xF2A445))
    public static let danger = Color.adaptive(0xCA282E, 0xF36368, increased: (0xBD252B, 0xF47478))
    public static let primary = Color.adaptive(0x1C1C1E, 0xECEDF1)
    public static let onPrimary = Color.adaptive(0xFFFFFF, 0x111216)
    public static let onAccent = Color.adaptive(0xFFFFFF, 0x111216)      // on an accent fill: 5.4:1 light, 6.2:1 dark
    public static let avatar = Color(uiColor: UIColor(hex: 0x247A43))    // one solid fill in both themes, white initial 5.3:1
    /// iPad: the widest a column of sentences gets (readable-width), centred.
    public static let readableWidth: CGFloat = 672
    /// iPad split view: the Targets list column (PageiPad 360; 320 at Split View 2/3, PageiPadSizes).
    public static let listColumn: CGFloat = 360
    public static let listColumnNarrow: CGFloat = 320

    /// How strongly a tint shows behind its glyph or word, with the Mac's names (G.Opacity). Pills sit lower
    /// than tiles, over an opaque card, so every status color keeps 4.6:1 or more on its pill.
    public enum Opacity {
        public static let tint: Double = 0.12           // opacity-tint: an icon tile's fill
        public static let pill: Double = 0.10           // a status pill over the card
        /// Pills and tiles with Increase Contrast, so the shape stands out from the card.
        public static let increased: Double = 0.16
        public static let banner: Double = 0.10         // opacity-banner: a banner's tint over the card
        public static let attentionEdge: Double = 0.25  // a warn card's outline, as a banner's

        /// The tile tint for this contrast: read `@Environment(\.colorSchemeContrast)` in the view.
        public static func tint(_ contrast: ColorSchemeContrast) -> Double { contrast == .increased ? increased : tint }
        /// The pill tint for this contrast.
        public static func pill(_ contrast: ColorSchemeContrast) -> Double { contrast == .increased ? increased : pill }
    }

    /// Corner radii (radius-8, radius-12): code and chips, cards and bubbles.
    public enum Radius {
        public static let r8: CGFloat = 8
        public static let r12: CGFloat = 12
    }

    /// Spacing, from the vendored tokens (space-1 to space-3), with the Mac's names.
    public enum Space {
        public static let s4 = CGFloat(GlamorTokens.Length.space1)
        public static let s8 = CGFloat(GlamorTokens.Length.space2)
        public static let s12 = CGFloat(GlamorTokens.Length.space3)
    }

    /// Symbol boxes, from the vendored tokens (icon.sm to icon.lg), with the Mac's names.
    public enum Icon {
        public static let sm = CGFloat(GlamorTokens.Length.iconSm)
        public static let md = CGFloat(GlamorTokens.Length.iconMd)
        public static let lg = CGFloat(GlamorTokens.Length.iconLg)
    }

    /// Icon tiles and their glyphs, as on the Mac: 20 → 12, 28 and 32 → 16, 40 and up → 20.
    public enum Tile {
        /// A tile's corner is a quarter of its side, as on the Mac.
        public static let radiusRatio: CGFloat = 0.25
        public static let t20: CGFloat = 20
        public static let t32: CGFloat = 32
        public static let t40: CGFloat = 40
        public static func glyph(_ tile: CGFloat) -> CGFloat {
            switch tile {
            case ...t20: Icon.sm
            case ...t32: Icon.md
            default: Icon.lg
            }
        }
    }

    /// Row heights on iOS.
    public enum Height {
        /// A one-line loading row: the spinner's height, so the row does not jump when its words appear.
        public static let row20: CGFloat = 20
    }

    /// A status dot, as the Mac's G.Dot.d8.
    public enum Dot {
        public static let d8: CGFloat = 8
    }

    /// The least side of anything a finger taps (touch-44, the vendored tap.min).
    public static let touch = CGFloat(GlamorTokens.Length.tapMin)

    // Text: iOS text styles, so every size grows with the person's Dynamic Type setting, chosen so that at the
    // default setting each one is on the design system's scale: tokens ios-title, ios-headline, ios-body,
    // ios-small, ios-caption and ios-tiny (20 17 15 13 12 11). Touch targets are touch-44.
    public static let title = Font.system(.title3, weight: .semibold)      // 20
    public static let headline = Font.system(.headline)                     // 17 semibold
    public static let body = Font.system(.subheadline)                      // 15
    public static let bodyStrong = Font.system(.subheadline, weight: .semibold)
    public static let small = Font.system(.footnote)                        // 13
    public static let caption = Font.system(.caption)                       // 12
    public static let captionStrong = Font.system(.caption, weight: .semibold)
    public static let tiny = Font.system(.caption2)                         // 11
    public static let icon = Font.system(.title3)                           // 20, a symbol in a 44-point target
    // Dynamic Type styles, so mono text grows with the person's text size (footnote is 13, caption 12 at default).
    public static let mono = Font.system(.footnote, design: .monospaced)
    public static let monoSmall = Font.system(.caption, design: .monospaced)
    public static let monoTiny = Font.system(.caption2, design: .monospaced)
}
#endif
