#if os(macOS)
import Glamor
import SwiftUI

/// The person the profile and rail scenes draw. A name is data, not a word to translate, and this one is a placeholder,
/// not a real person; the detail line and the menu rows are words, from the gallery's catalog. Glamor holds none of this.
enum ProfileDemo {
    static let name = "Alex Morgan"

    static var detail: String { Words.text("profile.detail") }

    /// The card, with the demo's menu behind it, in the style the scene needs.
    @MainActor static func card(_ style: ProfileCardStyle) -> some View {
        ProfileCard(name: name, detail: detail, style: style) { ProfileDemoMenu() }
    }
}
#endif
