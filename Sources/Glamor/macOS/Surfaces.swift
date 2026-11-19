#if os(macOS)
import AppKit
import SwiftUI

// MARK: Building blocks

/// A rounded square with an icon, tinted softly.
public struct IconTile: View {
    public let symbol: String
    public var tint: Color = G.accentFg
    public var size: CGFloat = G.Tile.t32
    @Environment(\.colorSchemeContrast) private var contrast
    public var body: some View {
        Image(systemName: symbol)
            .font(.system(size: G.Icon.point(G.Tile.glyph(size)), weight: .medium))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(G.Opacity.tint(contrast)),
                        in: RoundedRectangle(cornerRadius: size * G.Radius.tile, style: .continuous))
            .accessibilityHidden(true)    // always beside the words it stands for
    }

    public init(symbol: String, tint: Color = G.accentFg, size: CGFloat = G.Tile.t32) {
        self.symbol = symbol
        self.tint = tint
        self.size = size
    }
}

public struct StatusDot: View {
    public var color: Color
    public var size: CGFloat = G.Dot.d8
    // Never the only signal: the word beside it says the same, and VoiceOver reads that word
    // (StatusDot). A caller with no word beside it labels the dot itself.
    public var body: some View { Circle().fill(color).frame(width: size, height: size).accessibilityHidden(true) }

    public init(color: Color, size: CGFloat = G.Dot.d8) {
        self.color = color
        self.size = size
    }
}

/// A dashed rule between the sections of a page.
public struct DashedDivider: View {
    public var body: some View {
        Line().stroke(G.border, style: StrokeStyle(lineWidth: G.Line.hair, dash: [G.Space.s4, G.Space.s4]))
            .frame(height: G.Line.hair)
    }
    public struct Line: Shape {
        public func path(in r: CGRect) -> Path { Path { p in p.move(to: CGPoint(x: 0, y: r.midY)); p.addLine(to: CGPoint(x: r.maxX, y: r.midY)) } }
    }
}

/// A hairline between rows or above a bar.
public struct Hairline: View {
    public var color: Color = G.border
    public var body: some View { Rectangle().fill(color).frame(height: G.Line.hair) }

    public init(color: Color = G.border) {
        self.color = color
    }
}

public extension View {
    /// A card: white (or dark), rounded, a hairline border. `hover` and `pressed` are for a card that is a
    /// raised control (HoverCard, the profile row): cardHover, then G.Hover.pressed. Items inside hover on `.card`.
    func card(padding: CGFloat = 0, hover: Bool = false, pressed: Bool = false) -> some View {
        self.hoverGround(.card)
            .padding(padding)
            .background(pressed ? G.Hover.pressed : (hover ? G.cardHover : G.card),
                        in: RoundedRectangle(cornerRadius: G.radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: G.radius, style: .continuous).strokeBorder(G.border))
    }

    /// A quiet panel for output and code.
    func surface(padding: CGFloat = 0) -> some View {
        self.padding(padding)
            .background(G.subtle, in: RoundedRectangle(cornerRadius: G.Radius.r8, style: .continuous))
    }
}

/// A card that lights up under the pointer and can be clicked.
public struct HoverCard<Content: View>: View {
    public var action: () -> Void
    @ViewBuilder public var content: () -> Content
    @State private var hover = false
    public var body: some View {
        Button(action: action) {
            PressedReader { pressed in
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .card(padding: G.Space.s16, hover: hover, pressed: pressed)
                    .shadow(hover && !pressed ? G.Shadow.hover : G.Shadow.none)
            }
        }
        .buttonStyle(.plainFocus(G.radius))
        .onHover { hover = $0 }
    }

    public init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }
}

/// Lets the window be dragged by this area, as by a title bar.
public struct WindowDragArea: NSViewRepresentable {
    final public class DragView: NSView {
        public override var mouseDownCanMoveWindow: Bool { true }
        public override func mouseDown(with event: NSEvent) {
            if event.clickCount == 2 { window?.zoom(nil) } else { window?.performDrag(with: event) }
        }
    }
    public func makeNSView(context: Context) -> NSView { DragView() }
    public func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif
