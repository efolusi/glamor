#if os(iOS)
import SwiftUI
import UIKit

// The design system's tokens (design/tokens.json) on iOS: the same colors and status meanings as the
// Mac. Sizes and navigation follow iOS (Platforms table: "Navigation and sizes from the iOS conventions").

public extension Color {
    /// A design-tokens colour (Generated/GlamorTokens.swift): its light and dark values, and their pair
    /// for Increase Contrast.
    init(_ pair: GlamorTokens.ColorPair) {
        self.init(uiColor: UIColor { t in
            let high = t.accessibilityContrast == .high
            let c = t.userInterfaceStyle == .dark ? (high ? pair.increasedDark : pair.dark) : (high ? pair.increasedLight : pair.light)
            return UIColor(red: c.red, green: c.green, blue: c.blue, alpha: c.alpha)
        })
    }
}

private typealias T = GlamorTokens.Color

public enum G {
    // Every colour comes from design-tokens, with the Mac's names (one brand with Meridian).
    public static let window = Color(T.surfacePage)
    public static let card = Color(T.surfaceCard)
    public static let subtle = Color(T.surfaceSunken)
    public static let border = Color(T.borderDefault)              // decorative; the control edge with Increase Contrast
    public static let controlEdge = Color(T.borderControl)         // a control's outline, 3:1 or more
    public static let text = Color(T.textPrimary)
    public static let text2 = Color(T.textSecondary)
    public static let text3 = Color(T.textMuted)                   // text2 with Increase Contrast
    public static let accent = Color(T.accent)                     // the copper fill of the main button; never text, never a shape's only edge
    public static let accentEdge = Color(T.accentEdge)             // the accent as a shape on a light ground: 3:1 or more
    public static let onAccent = Color(T.accentContrast)           // the ink on an accent fill
    public static let accentFg = Color(T.accentSubtleFg)           // the brand's brown for a glyph on a tint
    public static let ok = Color(T.success600)
    public static let warn = Color(T.warning600)
    public static let danger = Color(T.danger600)
    public static let avatar = Color(T.avatarBg)
    public static let onAvatar = Color(T.avatarFg)
    /// iPad: the widest a column of sentences gets (readable-width), centred.
    public static let readableWidth: CGFloat = 672
    /// iPad split view: the Targets list column (PageiPad 360; 320 at Split View 2/3, PageiPadSizes).
    public static let listColumn: CGFloat = 360
    public static let listColumnNarrow: CGFloat = 320

    /// How strongly a tint shows behind its glyph or word, with the Mac's names (G.Opacity). Pills sit lower
    /// than tiles, over an opaque card, so every status color keeps 4.5:1 or more on its pill.
    public enum Opacity {
        public static let tint: Double = 0.12           // opacity-tint: an icon tile's fill
        public static let pill: Double = 0.10           // a status pill over the card
        /// Pills and tiles with Increase Contrast, so the shape stands out from the card.
        public static let increased: Double = 0.16
        public static let banner: Double = 0.10         // opacity-banner: a banner's tint over the card
        public static let attentionEdge: Double = 0.25  // a warn card's outline, as a banner's
        public static let disabled: Double = 0.3        // the main action when disabled, as on the Mac

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
        /// The gap between a label and its icon, as on the Mac: design-tokens space-2.
        public static let labelIcon = CGFloat(GlamorTokens.Length.space2)
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

    /// Hairlines and borders, as the Mac's G.Line.hair: the main action's 1px accent rim.
    public enum Line {
        public static let hair: CGFloat = 1
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
