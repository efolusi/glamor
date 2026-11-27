#if os(iOS)
import SwiftUI

/// The look of a sidebar row on iPad and iPhone: the Mac's (the `panel` fill, a hairline and the marker when chosen),
/// at least a touch target high. There is no hover on a touch screen; a press takes `G.Hover.pressed`. The height
/// is a floor, not a fixed size: a larger text setting makes the row taller instead of clipping it. The system draws
/// the keyboard focus on a row, so no ring is drawn here.
struct SidebarItemStyle: ButtonStyle {
    /// The least height of a row: `G.touch` (44).
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
