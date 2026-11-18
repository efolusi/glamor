import AppKit
import SwiftUI

// MARK: Building blocks

/// A rounded square with an icon, tinted softly.
struct IconTile: View {
    let symbol: String
    var tint: Color = K.accent
    var size: CGFloat = K.Tile.t32
    @Environment(\.colorSchemeContrast) private var contrast
    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: K.Icon.point(K.Tile.glyph(size)), weight: .medium))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(K.Opacity.tint(contrast)),
                        in: RoundedRectangle(cornerRadius: size * K.Radius.tile, style: .continuous))
            .accessibilityHidden(true)    // always beside the words it stands for
    }
}

struct StatusDot: View {
    var color: Color
    var size: CGFloat = K.Dot.d8
    // Never the only signal: the word beside it says the same, and VoiceOver reads that word
    // (StatusDot). A caller with no word beside it labels the dot itself.
    var body: some View { Circle().fill(color).frame(width: size, height: size).accessibilityHidden(true) }
}

/// A dashed rule between the sections of a page.
struct DashedDivider: View {
    var body: some View {
        Line().stroke(K.border, style: StrokeStyle(lineWidth: K.Line.hair, dash: [K.Space.s4, K.Space.s4]))
            .frame(height: K.Line.hair)
    }
    struct Line: Shape {
        func path(in r: CGRect) -> Path { Path { p in p.move(to: CGPoint(x: 0, y: r.midY)); p.addLine(to: CGPoint(x: r.maxX, y: r.midY)) } }
    }
}

/// A hairline between rows or above a bar.
struct Hairline: View {
    var color: Color = K.border
    var body: some View { Rectangle().fill(color).frame(height: K.Line.hair) }
}

extension View {
    /// A card: white (or dark), rounded, a hairline border. `hover` and `pressed` are for a card that is a
    /// raised control (HoverCard, the profile row): cardHover, then K.Hover.pressed. Items inside hover on `.card`.
    func card(padding: CGFloat = 0, hover: Bool = false, pressed: Bool = false) -> some View {
        self.hoverGround(.card)
            .padding(padding)
            .background(pressed ? K.Hover.pressed : (hover ? K.cardHover : K.card),
                        in: RoundedRectangle(cornerRadius: K.radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: K.radius, style: .continuous).strokeBorder(K.border))
    }

    /// A quiet panel for output and code.
    func surface(padding: CGFloat = 0) -> some View {
        self.padding(padding)
            .background(K.subtle, in: RoundedRectangle(cornerRadius: K.Radius.r8, style: .continuous))
    }
}

/// A card that lights up under the pointer and can be clicked.
struct HoverCard<Content: View>: View {
    var action: () -> Void
    @ViewBuilder var content: () -> Content
    @State private var hover = false
    var body: some View {
        Button(action: action) {
            PressedReader { pressed in
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .card(padding: K.Space.s16, hover: hover, pressed: pressed)
                    .shadow(hover && !pressed ? K.Shadow.hover : K.Shadow.none)
            }
        }
        .buttonStyle(.plainFocus(K.radius))
        .onHover { hover = $0 }
    }
}

/// Lets the window be dragged by this area, as by a title bar.
struct WindowDragArea: NSViewRepresentable {
    final class DragView: NSView {
        override var mouseDownCanMoveWindow: Bool { true }
        override func mouseDown(with event: NSEvent) {
            if event.clickCount == 2 { window?.zoom(nil) } else { window?.performDrag(with: event) }
        }
    }
    func makeNSView(context: Context) -> NSView { DragView() }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
