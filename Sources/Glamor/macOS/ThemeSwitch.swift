#if os(macOS)
import SwiftUI

/// What the theme switch says to VoiceOver and in its tooltip: the action it will do, not the state it is in.
public enum ThemeSwitchWords {
    public static func next(after current: Appearance) -> Appearance { current == .light ? .dark : .light }

    public static func label(current: Appearance) -> String {
        "Switch to the \(next(after: current).rawValue.lowercased()) theme"
    }
}

/// The theme switch: one glass button that moves between light and dark. There is no system choice.
/// Tab reaches it, Space or Return switches.
public struct ThemeSwitch: View {
    @Binding public var appearance: Appearance

    public var body: some View {
        let label = ThemeSwitchWords.label(current: appearance)
        Button { appearance = ThemeSwitchWords.next(after: appearance) } label: {
            Image(systemName: appearance == .light ? "moon" : "sun.max")
                .icon(G.Icon.md)
                .frame(width: G.Height.control24, height: G.Height.control24)
        }
        .glassButton(fallback: SecondaryButtonStyle(compact: true))
        .help(label)
        .accessibilityLabel(label)
    }

    public init(appearance: Binding<Appearance>) {
        self._appearance = appearance
    }
}
#endif
