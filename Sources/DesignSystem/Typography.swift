import AppKit
import SwiftUI

/// A type style: its font, the line it sits on (16 for 11 to 13 point text, 20 for title-s, 24 for
/// title-m and title-l, so blocks of text are whole multiples of 4 high), and how far its glyphs move
/// down to sit centred in that line, as a fixed-height frame would centre them.
struct TextStyle {
    var font: Font
    var line: CGFloat
    var shift: CGFloat

    func weight(_ weight: Font.Weight) -> TextStyle { TextStyle(font: font.weight(weight), line: line, shift: shift) }

    static let titleL = TextStyle(font: K.Font.titleL, line: K.Height.line24, shift: -1)
    static let titleM = TextStyle(font: K.Font.titleM, line: K.Height.line24, shift: 1)
    static let titleS = TextStyle(font: K.Font.titleS, line: K.Height.line20, shift: 0.5)
    static let bodyStrong = TextStyle(font: K.Font.bodyStrong, line: K.Height.line16, shift: 0)
    static let bodyMedium = TextStyle(font: K.Font.bodyMedium, line: K.Height.line16, shift: 0)
    static let body = TextStyle(font: K.Font.body, line: K.Height.line16, shift: 0)
    static let caption = TextStyle(font: K.Font.caption, line: K.Height.line16, shift: 0.5)
    static let small = TextStyle(font: K.Font.small, line: K.Height.line16, shift: 1)
    static let sectionLabel = TextStyle(font: K.Font.sectionLabel, line: K.Height.line16, shift: 1)
    static let inputL = TextStyle(font: K.Font.inputL, line: K.Height.line24, shift: 1)
    static let monoL = TextStyle(font: K.Font.monoL, line: K.Height.line16, shift: 0)
    static let mono = TextStyle(font: K.Font.mono, line: K.Height.line16, shift: 0.5)
    static let monoS = TextStyle(font: K.Font.monoS, line: K.Height.line16, shift: 1)

    /// Body text that turns semibold when its row or tab is selected.
}

extension View {
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

extension Image {
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
        font(.system(size: K.Icon.point(box), weight: weight)).frame(width: box, height: box)
    }
}

enum Appearance: String, CaseIterable, Identifiable {
    case system = "System", light = "Light", dark = "Dark"
    var id: String { rawValue }
    var scheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
