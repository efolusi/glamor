#if os(macOS)
import Glamor
import SwiftUI

/// What the profile card opens in the demo: the person, then three rows. Each row records its name, so the window check
/// can see that it is a control inside the popover. The real menu is the app's.
struct ProfileDemoMenu: View {
    /// The three rows: the key the window check reads from the window title, and the word, each from the catalog.
    private static let rows = [("appearance", Words.text("profile.appearance")), ("upgrade", Words.text("profile.upgrade")),
                               ("settings", Words.text("profile.settings"))]

    var body: some View {
        VStack(alignment: .leading, spacing: G.Row.gap) {
            Text(verbatim: ProfileDemo.name).textStyle(.bodyMedium).foregroundStyle(G.text)
            Text(ProfileDemo.detail).textStyle(.caption).foregroundStyle(G.text2)
            Hairline().padding(.vertical, G.Space.s4)
            ForEach(Self.rows, id: \.0) { key, word in
                Button { activated(key) } label: { Text(word).frame(maxWidth: .infinity, alignment: .leading) }
                    .buttonStyle(GhostButtonStyle(wide: true))
            }
        }
        .padding(G.Row.listInset)
    }
}
#endif
