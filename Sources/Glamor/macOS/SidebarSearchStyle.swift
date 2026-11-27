#if os(macOS)
import SwiftUI

/// The look of `SidebarSearch`: a 32 high capsule on the `field` fill with the control edge (3:1 off the window
/// ground), the muted placeholder colour at rest and `text2` under the pointer. Pressed takes `G.Hover.pressed`.
/// The focus ring is the capsule ring, drawn here where the button's own focus is read.
struct SidebarSearchStyle: ButtonStyle {
    @State private var hover = false

    func makeBody(configuration: Configuration) -> some View {
        let active = hover || configuration.isPressed
        configuration.label
            .foregroundStyle(active ? G.text2 : G.placeholder)
            .padding(.horizontal, G.Space.s12)
            .frame(maxWidth: .infinity, minHeight: G.Height.control32, maxHeight: G.Height.control32, alignment: .leading)
            .background(configuration.isPressed ? G.Hover.pressed : G.field, in: Capsule())
            .overlay(Capsule().strokeBorder(G.controlEdge, lineWidth: G.Line.hair))
            .contentShape(Capsule())
            .focusRingCapsule()
            .onHover { hover = $0 }
    }
}
#endif
