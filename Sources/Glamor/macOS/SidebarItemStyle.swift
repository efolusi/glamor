#if os(macOS)
import SwiftUI

/// The look of a sidebar row (variant A). Not `RowStyle`: a lists-on-card row selects with `accentSubtle`, the sidebar
/// selects with the `panel` fill, a hairline and the marker, as in the mocks the owner chose. Same sizes from `G.Row`.
/// Under the pointer the row takes the hover fill of the window, pressed `G.Hover.pressed`. The focus ring sits inside
/// the row's own shape, where the button's focus is read.
struct SidebarItemStyle: ButtonStyle {
    let isSelected: Bool
    @State private var hover = false

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: G.Row.radius, style: .continuous)
        let fill: Color = configuration.isPressed ? G.Hover.pressed
            : (isSelected ? G.panel : G.Hover.item(hover: hover, pressed: false, on: .window))
        configuration.label
            .padding(.horizontal, G.Row.padding)
            .frame(maxWidth: .infinity, minHeight: G.Row.oneLine, maxHeight: G.Row.oneLine, alignment: .leading)
            .contentShape(shape)
            .background(fill, in: shape)
            .overlay { if isSelected { shape.strokeBorder(G.border, lineWidth: G.Line.hair) } }
            .selectedMarker(isSelected)
            .focusRingInside()
            .onHover { hover = $0 }
    }
}
#endif
