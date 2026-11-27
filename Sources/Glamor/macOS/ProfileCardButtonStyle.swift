#if os(macOS)
import SwiftUI

/// The look of `ProfileCard`: a raised control, not a list row. Bare at rest, `cardHover` under the pointer, `G.Hover.pressed`
/// when pressed, and no shadow (a HoverCard's shadow would lift the sidebar's footer off the window). The row's focus ring
/// is drawn inside its own shape, like a sidebar row; the avatar is a 44 point square, so its ring is the capsule (a circle).
struct ProfileCardButtonStyle: ButtonStyle {
    let style: ProfileCardStyle
    @State private var hover = false

    func makeBody(configuration: Configuration) -> some View {
        let fill: Color = configuration.isPressed ? G.Hover.pressed : (hover ? G.cardHover : .clear)
        switch style {
        case .row:
            let shape = RoundedRectangle(cornerRadius: G.Row.radius, style: .continuous)
            configuration.label
                .padding(.horizontal, G.Row.padding)
                .frame(maxWidth: .infinity, minHeight: G.Height.row52, maxHeight: G.Height.row52, alignment: .leading)
                .contentShape(shape)
                .background(fill, in: shape)
                .focusRingInside()
                .onHover { hover = $0 }
        case .avatar:
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
