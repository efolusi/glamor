#if os(macOS)
import SwiftUI

// Hover and pressed (design/README.md › States). Items take the hover fill of the ground they sit on, so
// every hover is about as visible as every other in both themes; raised controls take cardHover; anything
// pressed takes G.Hover.pressed. Nothing fades on press, and hover never uses accent or a status colour.

/// What an item sits on, which picks its hover fill.
public enum HoverGround: Sendable {
    case card, panel, window
}

public extension G.Hover {
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
        pressed ? G.Hover.pressed : (hover ? fill(on: ground) : .clear)
    }
}

private struct HoverGroundKey: EnvironmentKey { static let defaultValue = HoverGround.panel }
private struct ButtonPressedKey: EnvironmentKey { static let defaultValue = false }

public extension EnvironmentValues {
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

public extension View {
    /// Tells the items inside which ground they sit on.
    func hoverGround(_ ground: HoverGround) -> some View { environment(\.hoverGround, ground) }
}

/// Reads whether the surrounding `.plainFocus` button is pressed, for a label that draws its own fill.
public struct PressedReader<Content: View>: View {
    @Environment(\.buttonPressed) private var pressed
    @ViewBuilder public var content: (Bool) -> Content
    public var body: some View { content(pressed) }

    public init(@ViewBuilder content: @escaping (Bool) -> Content) {
        self.content = content
    }
}
#endif
