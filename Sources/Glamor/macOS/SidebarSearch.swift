#if os(macOS)
import SwiftUI

/// The capsule at the top of the sidebar that opens the command palette (⌘K). It is a button, not a text field: the
/// palette and its key binding stay the app's, and `action` is what opens it. The shortcut is drawn as a badge and
/// repeated in the tooltip; VoiceOver reads the name once.
public struct SidebarSearch: View {
    public let title: String
    public let shortcut: String
    public let action: () -> Void

    /// The key that opens the palette in every Efolusi app. A key chord is not a translated word.
    public static let defaultShortcut = "⌘K"

    /// `title` is the app's own word when it has one; the default is "Search" ("Cari").
    public init(title: String? = nil, shortcut: String = SidebarSearch.defaultShortcut, action: @escaping () -> Void) {
        self.title = title ?? GlamorText.string(.searchTitle)
        self.shortcut = shortcut
        self.action = action
    }

    var tooltip: String { "\(title) (\(shortcut))" }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: G.Space.labelIcon) {
                Image(systemName: "magnifyingglass").icon(G.Icon.md).foregroundStyle(G.text3)
                Text(title).textStyle(.body).lineLimit(1)
                Spacer(minLength: G.Space.s8)
                ShortcutBadge(text: shortcut).accessibilityHidden(true)
            }
        }
        .buttonStyle(SidebarSearchStyle())
        .help(tooltip)
        .accessibilityLabel(title)
    }
}
#endif
