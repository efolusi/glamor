#if os(macOS)
import SwiftUI

/// The look of `ProfileCard`: the sidebar's foot is ONE bordered account card. The `row` is the card at rest (`card` fill, a
/// `border` hairline, the card's 12 radius), `cardHover` under the pointer and `G.Hover.pressed` when pressed, and it casts no
/// shadow (a HoverCard's shadow would lift the sidebar's footer off the window). Its focus ring is drawn inside its own shape,
/// on the card's corners. The `avatar` is the circle alone, a 44 point square, so its ring is the capsule (a circle).
struct ProfileCardButtonStyle: ButtonStyle {
    let style: ProfileCardStyle
    @State private var hover = false

    /// The row's fill: the card at rest.
    static func fill(pressed: Bool, hover: Bool) -> Color {
        pressed ? G.Hover.pressed : (hover ? G.cardHover : G.card)
    }

    func makeBody(configuration: Configuration) -> some View {
        switch style {
        case .row:
            let shape = RoundedRectangle(cornerRadius: G.Radius.r12, style: .continuous)
            configuration.label
                .padding(.horizontal, G.Row.padding)
                .frame(maxWidth: .infinity, minHeight: G.Height.row52, maxHeight: G.Height.row52, alignment: .leading)
                .contentShape(shape)
                .background(Self.fill(pressed: configuration.isPressed, hover: hover), in: shape)
                .overlay { shape.strokeBorder(G.border, lineWidth: G.Line.hair) }
                .focusRingInside(radius: G.Radius.r12)
                .onHover { hover = $0 }
        case .avatar:
            // The circle draws its own ring; at rest the 44 target is bare, under the pointer it takes `cardHover`.
            let fill: Color = configuration.isPressed ? G.Hover.pressed : (hover ? G.cardHover : .clear)
            configuration.label
                .frame(width: G.Height.toolbar, height: G.Height.toolbar)
                .contentShape(Circle())
                .background(fill, in: Circle())
                .focusRingCapsule()
                .onHover { hover = $0 }
        }
    }
}
#endif
