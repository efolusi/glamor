#if os(iOS)
import SwiftUI

/// `size` is the side at the default text size; the tile grows with Dynamic Type,
/// and Smart Invert leaves its colors alone.
public struct IconTile: View {
    public let symbol: String
    public var tint: Color = G.accent
    public var size: CGFloat = 32
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1
    @Environment(\.colorSchemeContrast) private var contrast
    public var body: some View {
        let side = size * scale
        Image(systemName: symbol)
            .font(.system(size: side * 0.5, weight: .medium))
            .foregroundStyle(tint)
            .frame(width: side, height: side)
            .background(tint.opacity(G.Tint.tile(contrast)), in: RoundedRectangle(cornerRadius: side * 0.25, style: .continuous))
            .accessibilityIgnoresInvertColors()
            .accessibilityHidden(true)   // decorative: the row's own text names the thing
    }

    public init(symbol: String, tint: Color = G.accent, size: CGFloat = 32) {
        self.symbol = symbol
        self.tint = tint
        self.size = size
    }
}

/// 8 at the default text size, growing with Dynamic Type.
public struct StatusDot: View {
    public var color: Color
    @ScaledMetric(relativeTo: .subheadline) private var side: CGFloat = 8
    public var body: some View { Circle().fill(color).frame(width: side, height: side) }

    public init(color: Color) {
        self.color = color
    }
}

public struct Pill: View {
    public let text: String
    public var color: Color = G.text2
    @Environment(\.colorSchemeContrast) private var contrast
    public var body: some View {
        // caption2 (11 at default) grows with Dynamic Type; padding instead of a fixed height so it never clips.
        // A 10% tint on an opaque card ground, so the row behind never shows through: every status color
        // reads 4.6:1 or more in both themes (the same value as the Mac's G.Opacity.pill).
        Text(DisplayText.line(text)).font(G.tiny.weight(.medium))
            .padding(.horizontal, 8).padding(.vertical, 4)
            .foregroundStyle(color)
            .background(color.opacity(G.Tint.pill(contrast)), in: Capsule())
            .background(G.card, in: Capsule())
    }

    public init(text: String, color: Color = G.text2) {
        self.text = text
        self.color = color
    }
}

/// A finding's severity by shape as well as color (AttentionCard): a circle for a
/// problem, a triangle for a warning, 20 at the default size and growing with the text. VoiceOver reads
/// the word, "Problem" or "Warning".
public struct SeverityMark: View {
    public let problem: Bool
    /// One width for both shapes, so every finding's sentence starts at the same place.
    @ScaledMetric(relativeTo: .title3) private var side: CGFloat = 20
    public var body: some View {
        Image(systemName: problem ? "exclamationmark.circle.fill" : "exclamationmark.triangle.fill")
            .font(G.icon)
            .frame(width: side)
            .foregroundStyle(problem ? G.danger : G.warn)
            .accessibilityLabel(problem ? "Problem" : "Warning")
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
