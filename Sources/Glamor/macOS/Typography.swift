#if os(macOS)
import AppKit
import SwiftUI

/// A type style: its font, the line it sits on (16 for 11 to 13 point text, 20 for title-s, 24 for
/// title-m and title-l, so blocks of text are whole multiples of 4 high), and how far its glyphs move
/// down to sit centred in that line, as a fixed-height frame would centre them.
public struct TextStyle {
    public var font: Font
    public var line: CGFloat
    public var shift: CGFloat

    public func weight(_ weight: Font.Weight) -> TextStyle { TextStyle(font: font.weight(weight), line: line, shift: shift) }

    public static let titleL = TextStyle(font: G.Font.titleL, line: G.Height.line24, shift: -1)
    public static let titleM = TextStyle(font: G.Font.titleM, line: G.Height.line24, shift: 1)
    public static let titleS = TextStyle(font: G.Font.titleS, line: G.Height.line20, shift: 0.5)
    public static let bodyStrong = TextStyle(font: G.Font.bodyStrong, line: G.Height.line16, shift: 0)
    public static let bodyMedium = TextStyle(font: G.Font.bodyMedium, line: G.Height.line16, shift: 0)
    public static let body = TextStyle(font: G.Font.body, line: G.Height.line16, shift: 0)
    public static let caption = TextStyle(font: G.Font.caption, line: G.Height.line16, shift: 0.5)
    public static let small = TextStyle(font: G.Font.small, line: G.Height.line16, shift: 1)
    public static let sectionLabel = TextStyle(font: G.Font.sectionLabel, line: G.Height.line16, shift: 1)
    public static let inputL = TextStyle(font: G.Font.inputL, line: G.Height.line24, shift: 1)
    public static let monoL = TextStyle(font: G.Font.monoL, line: G.Height.line16, shift: 0)
    public static let mono = TextStyle(font: G.Font.mono, line: G.Height.line16, shift: 0.5)
    public static let monoS = TextStyle(font: G.Font.monoS, line: G.Height.line16, shift: 1)

    /// Body text that turns semibold when its row or tab is selected.

    public init(font: Font, line: CGFloat, shift: CGFloat) {
        self.font = font
        self.line = line
        self.shift = shift
    }
}

public extension View {
    /// Sets a type style on this text and the text inside it. The line height and the centring need
    /// macOS 26; earlier versions keep the font's own line height.
    @ViewBuilder func textStyle(_ style: TextStyle) -> some View {
        if #available(macOS 26, *) {
            font(style.font).lineHeight(.exact(points: style.line)).baselineOffset(-style.shift)
        } else {
            font(style.font)
        }
    }
}

public extension Image {
    /// An SF Symbol on the icon scale, centred in a box of that size. It is decoration: the words beside it,
    /// or the button it sits in, say what it means, so VoiceOver skips it (it would read the symbol's name).
    func icon(_ box: CGFloat, weight: Font.Weight = .regular) -> some View {
        glyph(box, weight: weight).accessibilityHidden(true)
    }

    /// The same symbol when it says something the words beside it do not ("Primary key", "Warning"):
    /// VoiceOver reads `label`.
    func icon(_ box: CGFloat, weight: Font.Weight = .regular, label: String) -> some View {
        glyph(box, weight: weight).accessibilityLabel(label)
    }

    private func glyph(_ box: CGFloat, weight: Font.Weight) -> some View {
        font(.system(size: G.Icon.point(box), weight: weight)).frame(width: box, height: box)
    }
}

public enum Appearance: String, CaseIterable, Identifiable {
    case system = "System", light = "Light", dark = "Dark"
    public var id: String { rawValue }
    public var scheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
#endif
