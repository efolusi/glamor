#if os(macOS)
import SwiftUI

/// What the theme switch says to VoiceOver and in its tooltip: the action it will do, not the state it is in.
/// The caller must give the words in the person's language (no default); `english` and `indonesian` are Meridian's, and `current` follows the person's language. All three read the catalog.
public struct ThemeSwitchWords: Equatable, Sendable {
    public let toDark: String
    public let toLight: String

    public init(toDark: String, toLight: String) {
        self.toDark = toDark
        self.toLight = toLight
    }

    public static let english = ThemeSwitchWords(toDark: GlamorText.string(.themeToDark, language: "en"), toLight: GlamorText.string(.themeToLight, language: "en"))
    public static let indonesian = ThemeSwitchWords(toDark: GlamorText.string(.themeToDark, language: "id"), toLight: GlamorText.string(.themeToLight, language: "id"))
    /// The words in the person's language (English when the catalog has none for it). Still a choice the caller makes:
    /// `ThemeSwitch` has no default words.
    public static var current: ThemeSwitchWords { ThemeSwitchWords(toDark: GlamorText.string(.themeToDark), toLight: GlamorText.string(.themeToLight)) }

    public static func next(after current: Appearance) -> Appearance { current == .light ? .dark : .light }

    public func label(current: Appearance) -> String { current == .light ? toDark : toLight }
}

/// The theme switch: one glass button that moves between light and dark. There is no system choice.
/// Tab reaches it, Space or Return switches.
public struct ThemeSwitch: View {
    @Binding public var appearance: Appearance
    public var words: ThemeSwitchWords

    public var body: some View {
        let label = words.label(current: appearance)
        Button { appearance = ThemeSwitchWords.next(after: appearance) } label: {
            Image(systemName: appearance == .light ? "moon" : "sun.max")
                .icon(G.Icon.md)
                .frame(width: G.Height.control24, height: G.Height.control24)
        }
        .glassButton(fallback: SecondaryButtonStyle(compact: true))
        .help(label)
        .accessibilityLabel(label)
    }

    public init(appearance: Binding<Appearance>, words: ThemeSwitchWords) {
        self._appearance = appearance
        self.words = words
    }
}
#endif
