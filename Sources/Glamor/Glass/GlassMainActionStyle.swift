import SwiftUI

/// The main action on glass: system glass tinted ember, with the label in `G.onAccent`.
/// The system's `.glassProminent` paints its own label colour (light on the light ember of the dark theme,
/// 2.05:1) and ignores a `foregroundStyle` set outside it, so the label's colour is set here, inside the style.
/// `G.onAccent` is white on the light theme's ember (5.24:1) and the dark ink on the dark theme's (8.43:1);
/// ContrastTests measure both. The shape and size are the solid primary button's (32 high, `r8`), 44 high on iOS.
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
            .glassEffect(.regular.tint(G.accent), in: shape)
            .opacity(enabled ? 1 : G.Opacity.disabled)
            .focusRing(G.Radius.r8)
        #else
        label
            .font(G.bodyStrong)
            .frame(minHeight: G.touch)
            .glassEffect(.regular.tint(G.accent).interactive(), in: shape)
            .opacity(enabled ? 1 : G.Opacity.disabled)
        #endif
    }
}
