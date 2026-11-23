import SwiftUI

/// A surface that is system glass on macOS 26 and iOS 26, tinted with the warm material tint at the glass
/// strength, and the solid `fill` with a hairline `edge` everywhere else (see `GlassPath`).
/// `edgeOnGlass` keeps the hairline on glass too. A field's edge is promised 3:1 against the surface tokens only;
/// over photos, video or pure black or white content the caller puts a scrim behind it (the design-tokens rule for text).
/// A solid surface keeps the contact shadow of the control it replaces; glass casts none of its own colour.
private struct GlassSurface<S: InsettableShape>: ViewModifier {
    let shape: S
    let tinted: Bool
    let fill: Color
    let edge: Color
    let edgeOnGlass: Bool
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        let path = GlassPath.choose(reduceTransparency: reduceTransparency, increasedContrast: contrast == .increased,
                                    systemHasGlass: GlassPath.systemHasGlass)
        if path == .glass, #available(iOS 26, macOS 26, *) {
            content.glassEffect(tinted ? .regular.tint(Color(GlamorTokens.Color.materialTint).opacity(GlamorTokens.Number.glassStrength)) : .regular, in: shape)
                .overlay { if edgeOnGlass { shape.strokeBorder(edge, lineWidth: 1) } }
        } else {
            content
                .background(fill, in: shape)
                .overlay(shape.strokeBorder(edge, lineWidth: 1))
        }
    }
}

public extension View {
    /// Glass in `shape` where the system has it; the solid `fill` and `edge` below macOS 26 / iOS 26,
    /// with Reduce Transparency and with Increase Contrast.
    func glassSurface<S: InsettableShape>(in shape: S, tinted: Bool = true, fill: Color, edge: Color, edgeOnGlass: Bool = false) -> some View {
        modifier(GlassSurface(shape: shape, tinted: tinted, fill: fill, edge: edge, edgeOnGlass: edgeOnGlass))
    }
}

/// The glass button for a secondary action (theme switch, a toolbar button) where the system has glass;
/// `fallback` is the solid style everywhere else.
private struct GlassButton<Fallback: ButtonStyle>: ViewModifier {
    let prominent: Bool
    let fallback: Fallback
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        let path = GlassPath.choose(reduceTransparency: reduceTransparency, increasedContrast: contrast == .increased,
                                    systemHasGlass: GlassPath.systemHasGlass)
        if path == .glass, #available(iOS 26, macOS 26, *) {
            if prominent {
                content.buttonStyle(GlassMainActionStyle())    // ember glass, label in onAccent (see the style)
            } else {
                content.buttonStyle(.glass)
            }
        } else {
            content.buttonStyle(fallback)
        }
    }
}

public extension View {
    /// `.glass` on macOS 26 / iOS 26, otherwise `fallback`.
    func glassButton<Fallback: ButtonStyle>(fallback: Fallback) -> some View {
        modifier(GlassButton(prominent: false, fallback: fallback))
    }

    /// The main action: glass tinted ember on macOS 26 / iOS 26, with its label in `G.onAccent` (see
    /// `GlassMainActionStyle`), otherwise `fallback` (the solid primary button, which has a contact shadow and no glow).
    func glassMainAction<Fallback: ButtonStyle>(fallback: Fallback) -> some View {
        modifier(GlassButton(prominent: true, fallback: fallback))
    }
}

/// A bar (toolbar, status bar, tab bar of a window): system glass on macOS 26 / iOS 26; below that and with
/// Reduce Transparency or Increase Contrast the card color with one hairline on the side that meets the content.
private struct GlassBar: ViewModifier {
    let edge: VerticalEdge
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        let path = GlassPath.choose(reduceTransparency: reduceTransparency, increasedContrast: contrast == .increased,
                                    systemHasGlass: GlassPath.systemHasGlass)
        if path == .glass, #available(iOS 26, macOS 26, *) {
            content.glassEffect(.regular.tint(Color(GlamorTokens.Color.materialTint).opacity(GlamorTokens.Number.glassStrength)), in: Rectangle())
        } else {
            content
                .background(G.card)
                .overlay(alignment: edge == .top ? .bottom : .top) { Rectangle().fill(G.border).frame(height: 1) }
        }
    }
}

public extension View {
    /// The ground of a bar. `edge` is the side of the window the bar sits on.
    func glassBar(edge: VerticalEdge = .top) -> some View {
        modifier(GlassBar(edge: edge))
    }
}
