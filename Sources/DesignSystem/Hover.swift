import SwiftUI

// Hover and pressed (design/README.md › States). Items take the hover fill of the ground they sit on, so
// every hover is about as visible as every other in both themes; raised controls take cardHover; anything
// pressed takes K.Hover.pressed. Nothing fades on press, and hover never uses accent or a status colour.

/// What an item sits on, which picks its hover fill.
enum HoverGround: Sendable {
    case card, panel, window
}

extension K.Hover {
    /// The hover fill for an item on `ground`.
    static func fill(on ground: HoverGround) -> Color {
        switch ground {
        case .card: onCard
        case .panel: onPanel
        case .window: onWindow
        }
    }

    /// An item's fill: pressed wins over hover, and both over nothing.
    static func item(hover: Bool, pressed: Bool, on ground: HoverGround) -> Color {
        pressed ? K.Hover.pressed : (hover ? fill(on: ground) : .clear)
    }
}

private struct HoverGroundKey: EnvironmentKey { static let defaultValue = HoverGround.panel }
private struct ButtonPressedKey: EnvironmentKey { static let defaultValue = false }

extension EnvironmentValues {
    /// The ground under the views inside: `.card()` sets `.card`, the sidebar `.window`; the panel is the default.
    var hoverGround: HoverGround {
        get { self[HoverGroundKey.self] }
        set { self[HoverGroundKey.self] = newValue }
    }

    /// True while the mouse is down on the PlainFocusStyle button around this label.
    var buttonPressed: Bool {
        get { self[ButtonPressedKey.self] }
        set { self[ButtonPressedKey.self] = newValue }
    }
}

extension View {
    /// Tells the items inside which ground they sit on.
    func hoverGround(_ ground: HoverGround) -> some View { environment(\.hoverGround, ground) }
}

/// Reads whether the surrounding `.plainFocus` button is pressed, for a label that draws its own fill.
struct PressedReader<Content: View>: View {
    @Environment(\.buttonPressed) private var pressed
    @ViewBuilder var content: (Bool) -> Content
    var body: some View { content(pressed) }
}
