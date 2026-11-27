import SwiftUI

/// The main action on glass: system glass tinted copper (translucent, so the ground shows through), with the label
/// in `G.onAccent` and a 1px `G.accentEdge` line drawn inside the shape over the glass. In light copper is 2.7:1 on a
/// card and the line is 4.6:1. In dark the line is the colour of the tint, but the glass is translucent, so a 1px
/// copper line may still show against it; what it looks like on screen is for the window check to judge.
/// The system's `.glassProminent` paints its own label colour (light on the dark theme's accent, 2.05:1 on the old
/// one) and ignores a `foregroundStyle` set outside it, so the label's colour is set here, inside the style.
/// `G.onAccent` is the dark ink on copper in both themes (6.37:1); ContrastTests measure both.
/// The shape and size are the solid primary button's (32 high, `r8`), 44 high on iOS.
/// Disabled: the tint and the rim fade to 30% and the label is `G.text3`. The whole view does not fade, because
/// ink at 30% on that fill was 1.7 to 2.0:1 in dark (GL28).
@available(iOS 26, macOS 26, *)
struct GlassMainActionStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: G.Radius.r8, style: .continuous)
        let tint = enabled ? G.accent : G.accent.opacity(G.Opacity.disabled)
        let label = configuration.label
            .lineLimit(1)
            .foregroundStyle(enabled ? G.onAccent : G.text3)
            .padding(.horizontal, G.Space.s12)
        #if os(macOS)
        label
            .textStyle(.bodyStrong)
            .frame(height: G.Height.control32)
            .contentShape(shape)    // the whole button is the hit and accessibility area, not the label's 16 pt
            .glassEffect(.regular.tint(tint), in: shape)
            .overlay(shape.strokeBorder(G.accentEdge.opacity(enabled ? 1 : G.Opacity.disabled), lineWidth: G.Line.hair))
            .focusRing(G.Radius.r8)
        #else
        label
            .font(G.bodyStrong)
            .frame(minHeight: G.touch)
            .glassEffect(.regular.tint(tint).interactive(), in: shape)
            .overlay(shape.strokeBorder(G.accentEdge.opacity(enabled ? 1 : G.Opacity.disabled), lineWidth: G.Line.hair))
        #endif
    }
}
