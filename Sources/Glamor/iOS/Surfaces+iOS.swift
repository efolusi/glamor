#if os(iOS)
import SwiftUI

/// `size` is the side at the default text size; the tile grows with Dynamic Type,
/// and Smart Invert leaves its colors alone.
public struct IconTile: View {
    public let symbol: String
    public var tint: Color = G.accentFg
    public var size: CGFloat = G.Tile.t32
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1
    @Environment(\.colorSchemeContrast) private var contrast
    public var body: some View {
        let side = size * scale
        Image(systemName: symbol)
            .font(.system(size: G.Tile.glyph(size) * scale, weight: .medium))
            .foregroundStyle(tint)
            .frame(width: side, height: side)
            .background(tint.opacity(G.Opacity.tint(contrast)), in: RoundedRectangle(cornerRadius: side * G.Tile.radiusRatio, style: .continuous))
            .accessibilityIgnoresInvertColors()
            .accessibilityHidden(true)   // decorative: the row's own text names the thing
    }

    public init(symbol: String, tint: Color = G.accentFg, size: CGFloat = G.Tile.t32) {
        self.symbol = symbol
        self.tint = tint
        self.size = size
    }
}

/// 8 at the default text size, growing with Dynamic Type.
public struct StatusDot: View {
    public var color: Color
    @ScaledMetric(relativeTo: .subheadline) private var side: CGFloat = G.Dot.d8
    public var body: some View { Circle().fill(color).frame(width: side, height: side) }

    public init(color: Color) {
        self.color = color
    }
}

/// A word of status in a capsule: its tint on an opaque card ground. `Pill(mark:)` is the outlined Pro or Soon mark.
public struct Pill: View {
    public let text: String
    public var color: Color = G.text2
    /// Set by `init(mark:)`: the mark is outlined instead of tinted, and VoiceOver says what it means.
    public let mark: PlanMark?
    @Environment(\.colorSchemeContrast) private var contrast
    @ViewBuilder public var body: some View {
        // caption2 (11 at default) grows with Dynamic Type; padding instead of a fixed height so it never clips.
        let word = Text(DisplayText.line(text)).font(G.tiny.weight(.medium))
            .padding(.horizontal, G.Space.s8).padding(.vertical, G.Space.s4)
        if let mark {
            word.foregroundStyle(mark.label)
                .overlay(PlanMarkEdge(mark: mark))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(mark.spoken())
        } else {
            // A 10% tint on an opaque card ground, so the row behind never shows through: every status color
            // reads 4.6:1 or more in both themes (G.Opacity.pill, as on the Mac).
            word.foregroundStyle(color)
                .background(color.opacity(G.Opacity.pill(contrast)), in: Capsule())
                .background(G.card, in: Capsule())
        }
    }

    public init(text: String, color: Color = G.text2) {
        self.text = text
        self.color = color
        self.mark = nil
    }

    /// The Pro or Soon mark (GL36): the word and its outline from `PlanMark`, in the person's language.
    public init(mark: PlanMark) {
        self.text = mark.word()
        self.color = mark.label
        self.mark = mark
    }
}

/// A finding's severity by shape as well as color (AttentionCard): a circle for a
/// problem, a triangle for a warning, 20 at the default size and growing with the text. VoiceOver reads
/// the word, "Problem" or "Warning".
public struct SeverityMark: View {
    public let problem: Bool
    /// One width for both shapes, so every finding's sentence starts at the same place.
    @ScaledMetric(relativeTo: .title3) private var side: CGFloat = G.Icon.lg
    public var body: some View {
        Image(systemName: problem ? "exclamationmark.circle.fill" : "exclamationmark.triangle.fill")
            .font(G.icon)
            .frame(width: side)
            .foregroundStyle(problem ? G.danger : G.warn)
            .accessibilityLabel(problem ? GlamorText.string(.problem) : GlamorText.string(.warning))
    }

    public init(problem: Bool) {
        self.problem = problem
    }
}

public extension View {
    /// A column of sentences at most `readableWidth` wide, centred (iPad). The sides are the grouped
    /// background, the same color the List paints under its own rows, so the column has no visible edge.
    /// A grouped list keeps its grouped background on both sides. Compact width is narrower anyway.
    @ViewBuilder func readableWidth(grouped: Bool = true) -> some View {
        let column = frame(maxWidth: G.readableWidth).frame(maxWidth: .infinity)
        if grouped { column.background(Color(uiColor: .systemGroupedBackground)) } else { column }
    }
}
#endif
