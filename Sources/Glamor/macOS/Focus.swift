#if os(macOS)
import SwiftUI

// Keyboard focus (WCAG 2.4.7, design system: focus, focus-offset). With Keyboard navigation on, Tab moves
// through the buttons, and the focused one draws a 2-pt `focus` ring 2 outside its shape. macOS's own
// rectangle is off: it ignores rounded shapes, and a CardList's clip cuts it.

public struct FocusRing: ViewModifier {
    @Environment(\.isFocused) private var focused
    public let radius: CGFloat
    public var capsule: Bool = false
    /// A list row draws its ring inside, on the ListRow highlight's own shape (G.Row.radius): outside, a
    /// CardList's clip and the next row would cut it.
    public var inside: Bool = false

    public func body(content: Content) -> some View {
        content
            .overlay {
                if focused {
                    Group {
                        if inside {
                            RoundedRectangle(cornerRadius: G.Row.radius, style: .continuous)
                                .strokeBorder(G.focus, lineWidth: G.Line.strong)
                        } else if capsule { Capsule().strokeBorder(G.focus, lineWidth: G.Line.strong) }
                        else {
                            RoundedRectangle(cornerRadius: radius + G.Line.focusOffset + G.Line.strong, style: .continuous)
                                .strokeBorder(G.focus, lineWidth: G.Line.strong)
                        }
                    }
                    .padding(inside ? 0 : -(G.Line.focusOffset + G.Line.strong))
                    .allowsHitTesting(false)
                }
            }
            .focusEffectDisabled()
    }

    public init(radius: CGFloat, capsule: Bool = false, inside: Bool = false) {
        self.radius = radius
        self.capsule = capsule
        self.inside = inside
    }
}

public extension View {
    /// The keyboard focus ring for a control whose shape has corner radius `radius`.
    func focusRing(_ radius: CGFloat) -> some View { modifier(FocusRing(radius: radius)) }
    func focusRingCapsule() -> some View { modifier(FocusRing(radius: 0, capsule: true)) }
    /// The ring inside a list row, on its highlight's shape (a host, connection or job row).
    func focusRingInside() -> some View { modifier(FocusRing(radius: 0, inside: true)) }
}

/// `.plain` with the focus ring: for buttons whose label draws its own shape (rows, cards, tabs). Nothing fades
/// on press; a label that draws a fill reads `buttonPressed` (PressedReader) and takes G.Hover.pressed.
public struct PlainFocusStyle: ButtonStyle {
    public var radius: CGFloat = G.Radius.r8
    public var inside: Bool = false
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .environment(\.buttonPressed, configuration.isPressed)
            .modifier(FocusRing(radius: radius, inside: inside))
    }

    public init(radius: CGFloat = G.Radius.r8, inside: Bool = false) {
        self.radius = radius
        self.inside = inside
    }
}

public extension ButtonStyle where Self == PlainFocusStyle {
    /// `.plain`, plus the keyboard focus ring around a shape of corner radius `radius`.
    static func plainFocus(_ radius: CGFloat = G.Radius.r8) -> PlainFocusStyle { .init(radius: radius) }
    /// `.plain` for a row's button in a card (Hosts, Connections, Jobs): the ring on the row highlight's shape.
    static var plainFocusRow: PlainFocusStyle { .init(inside: true) }
}

// MARK: Selection (design system: selected-marker)

public extension View {
    /// A selected sidebar place or list row: a 2-pt bar, 16 high, centred at its leading edge. The
    /// fill alone is 1.1:1; the bar is 4.4:1 or more on every fill it sits on.
    func selectedMarker(_ on: Bool) -> some View {
        overlay(alignment: .leading) {
            if on {
                Capsule().fill(G.selectedMarker)
                    .frame(width: G.Line.strong, height: G.Height.line16)
                    .accessibilityHidden(true)
            }
        }
    }
}
#endif
