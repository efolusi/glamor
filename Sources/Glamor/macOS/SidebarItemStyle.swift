#if os(macOS)
import SwiftUI

/// The look of a sidebar row (variant A). Not `RowStyle`: a lists-on-card row selects with `accentSubtle`, the sidebar
/// selects with the `panel` fill, a hairline and the marker, as in the mocks the owner chose. Same sizes from `G.Row`.
/// Under the pointer the row takes the hover fill of the window, pressed `G.Hover.pressed`. The focus ring sits inside
/// the row's own shape, where the button's focus is read. The rail (variant B) draws the same look at 52 high with
/// its content centred; a sidebar row is 32 high with its content at the leading edge.
struct SidebarItemStyle: ButtonStyle {
    let isSelected: Bool
    var height: CGFloat = G.Row.oneLine
    var alignment: Alignment = .leading
    /// From the highlight's edge to the content on each side. The rail takes 0: its 64 wide button is all the room a title has.
    var horizontalPadding: CGFloat = G.Row.padding
    /// A marker of its own height and top (the rail's: beside the glyph); nil is the row's, 0.6 of its height, centred.
    var markerHeight: CGFloat? = nil
    var markerTop: CGFloat = 0
    @State private var hover = false

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: G.Row.radius, style: .continuous)
        let fill: Color = configuration.isPressed ? G.Hover.pressed
            : (isSelected ? G.panel : G.Hover.item(hover: hover, pressed: false, on: .window))
        configuration.label
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: alignment)
            .contentShape(shape)
            .background(fill, in: shape)
            .overlay { if isSelected { shape.strokeBorder(G.border, lineWidth: G.Line.hair) } }
            .selectedMarker(isSelected, height: markerHeight, top: markerTop)
            .focusRingInside()
            .onHover { hover = $0 }
    }
}
#endif
