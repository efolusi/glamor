import SwiftUI

/// The main action on glass: system glass tinted copper (translucent, so the ground shows through), with the label
/// in `G.onAccent` and a 1px `G.accentEdge` line drawn inside the shape over the glass. In light copper is 2.7:1 on a
/// card and the line is 4.6:1. In dark the line is the colour of the tint, but the glass is translucent, so a 1px
/// copper line may still show against it; what it looks like on screen is for the window check to judge.
/// The system's `.glassProminent` paints its own label colour (light on the dark theme's accent, 2.05:1 on the old
/// one) and ignores a `foregroundStyle` set outside it, so the label's colour is set here, inside the style.
/// `G.onAccent` is the dark ink on copper in both themes (6.37:1); ContrastTests measure both.
/// The shape and size are the solid primary button's (32 high, `r8`), 44 high on iOS.
@available(iOS 26, macOS 26, *)
struct GlassMainActionStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: G.Radius.r8, style: .continuous)
        let label = configuration.label
            .lineLimit(1)
            .foregroundStyle(G.onAccent)
            .padding(.horizontal, G.Space.s12)
        #if os(macOS)
        label
            .textStyle(.bodyStrong)
            .frame(height: G.Height.control32)
            .contentShape(shape)    // the whole button is the hit and accessibility area, not the label's 16 pt
            .glassEffect(.regular.tint(G.accent), in: shape)
            .overlay(shape.strokeBorder(G.accentEdge, lineWidth: G.Line.hair))
            .opacity(enabled ? 1 : G.Opacity.disabled)
            .focusRing(G.Radius.r8)
        #else
        label
            .font(G.bodyStrong)
            .frame(minHeight: G.touch)
            .glassEffect(.regular.tint(G.accent).interactive(), in: shape)
            .overlay(shape.strokeBorder(G.accentEdge, lineWidth: G.Line.hair))
            .opacity(enabled ? 1 : G.Opacity.disabled)
        #endif
    }
}
