#if os(iOS)
import SwiftUI

/// The look of a sidebar row on iPad and iPhone: the Mac's, at least a touch target high. A press takes
/// `G.Hover.pressed`, as there is no hover. The height is a floor, so large text makes the row taller instead of
/// clipping it. The system draws the keyboard focus, so no ring is drawn here.
struct SidebarItemStyle: ButtonStyle {
    static let minHeight = G.touch

    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: G.Row.radius, style: .continuous)
        let fill: Color = configuration.isPressed ? G.Hover.pressed : (isSelected ? G.panel : .clear)
        configuration.label
            .padding(.horizontal, G.Row.padding)
            .padding(.vertical, G.Space.s8)
            .frame(maxWidth: .infinity, minHeight: Self.minHeight, alignment: .leading)
            .contentShape(shape)
            .background(fill, in: shape)
            .overlay { if isSelected { shape.strokeBorder(G.border, lineWidth: G.Line.hair) } }
            .selectedMarker(isSelected)
    }
}
#endif
