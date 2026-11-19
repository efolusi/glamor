#if os(macOS)
import SwiftUI

// MARK: Buttons: 32 standard, 28 compact (toolbars, cards, table rows)

/// The size of a button: compact when asked, or under `.controlSize(.small)`.
private struct ButtonMetrics {
    let compact: Bool
    init(_ compact: Bool, _ controlSize: ControlSize) {
        self.compact = compact || controlSize == .small || controlSize == .mini
    }
    var height: CGFloat { compact ? G.Height.control28 : G.Height.control32 }
    var radius: CGFloat { compact ? G.Radius.r6 : G.Radius.r8 }
    /// The symbol beside a button's title is 12 at both sizes (design system: Button).
    var icon: CGFloat { G.Icon.sm }
}

/// A Label inside a button: the icon on the icon scale, 8 before its title.
public struct ButtonLabelStyle: LabelStyle {
    public var icon: CGFloat
    public var weight: Font.Weight
    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: G.Space.s8) {
            configuration.icon.font(.system(size: G.Icon.point(icon), weight: weight))
            configuration.title
        }
    }

    public init(icon: CGFloat, weight: Font.Weight) {
        self.icon = icon
        self.weight = weight
    }
}

/// "⌘N": a 16-point badge with the shortcut in `small`.
public struct ShortcutBadge: View {
    public let text: String
    public var onPrimary: Bool = false
    public var body: some View {
        Text(text).textStyle(.small)
            .padding(.horizontal, G.Space.s4)
            .frame(height: G.Height.control16)
            .background(onPrimary ? G.onAccent.opacity(G.Opacity.kbd) : .clear, in: RoundedRectangle(cornerRadius: G.Radius.r4))
            .overlay {
                if !onPrimary { RoundedRectangle(cornerRadius: G.Radius.r4).strokeBorder(G.border) }
            }
    }

    public init(text: String, onPrimary: Bool = false) {
        self.text = text
        self.onPrimary = onPrimary
    }
}

/// The main button: black in light mode, white in dark, with an optional shortcut badge.
public struct PrimaryButtonStyle: ButtonStyle {
    public var shortcut: String? = nil
    public var wide: Bool = false
    public var compact: Bool = false
    @Environment(\.isEnabled) private var enabled
    @Environment(\.controlSize) private var controlSize
    @State private var hover = false
    public func makeBody(configuration: Configuration) -> some View {
        let m = ButtonMetrics(compact, controlSize)
        // primary at rest, then primaryHover and primaryPressed (opaque, so the ground never shows through);
        // 30% when disabled.
        let fill: Color = !enabled ? G.accent.opacity(G.Opacity.disabled)
            : (configuration.isPressed ? G.accentPressed : (hover ? G.accentHover : G.accent))
        HStack(spacing: G.Space.s8) {
            configuration.label.lineLimit(1)
            if let shortcut { ShortcutBadge(text: shortcut, onPrimary: true) }
        }
        .textStyle(.bodyStrong)
        .labelStyle(ButtonLabelStyle(icon: m.icon, weight: .semibold))
        .foregroundStyle(G.onAccent)
        .padding(.horizontal, G.Space.s12)
        .frame(height: m.height)
        .frame(maxWidth: wide ? .infinity : nil)
        .background(fill, in: RoundedRectangle(cornerRadius: m.radius, style: .continuous))
        // The secondary's shadow: a bigger one made the primary look taller beside it (EmptyState review).
        .shadow(enabled ? G.Shadow.control : G.Shadow.none)
        .focusRing(m.radius)
        .onHover { hover = $0 }
    }

    public init(shortcut: String? = nil, wide: Bool = false, compact: Bool = false) {
        self.shortcut = shortcut
        self.wide = wide
        self.compact = compact
    }
}

/// A white raised button with a hairline border, as for "Update now".
public struct SecondaryButtonStyle: ButtonStyle {
    public var compact: Bool = false
    @Environment(\.isEnabled) private var enabled
    @Environment(\.controlSize) private var controlSize
    @State private var hover = false
    public func makeBody(configuration: Configuration) -> some View {
        let m = ButtonMetrics(compact, controlSize)
        configuration.label
            .lineLimit(1)
            .textStyle(.bodyMedium)
            .labelStyle(ButtonLabelStyle(icon: m.icon, weight: .medium))
            // A destructive one (Remove…) keeps the secondary frame with danger text (PageEditTarget).
            .foregroundStyle(!enabled ? G.text3 : configuration.role == .destructive ? G.danger : G.text)
            .padding(.horizontal, G.Space.s12)
            .frame(height: m.height)
            // card, cardHover under the pointer, G.Hover.pressed while pressed. A destructive one hovers the same.
            .background(configuration.isPressed ? G.Hover.pressed : (hover ? G.cardHover : G.card),
                        in: RoundedRectangle(cornerRadius: m.radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: m.radius, style: .continuous).strokeBorder(G.border))
            .shadow(G.Shadow.control)
            .focusRing(m.radius)
            .onHover { hover = $0 }
    }

    public init(compact: Bool = false) {
        self.compact = compact
    }
}

/// Text that gains a fill under the pointer. `square` makes an icon-only button as wide as it is
/// high; `size` sets that side (24 inside rows); `wide` fills the width, as a menu row.
public struct GhostButtonStyle: ButtonStyle {
    public var compact: Bool = false
    public var square: Bool = false
    public var size: CGFloat? = nil
    public var wide: Bool = false
    @Environment(\.isEnabled) private var enabled
    @Environment(\.controlSize) private var controlSize
    @Environment(\.hoverGround) private var ground
    @State private var hover = false
    public func makeBody(configuration: Configuration) -> some View {
        let m = ButtonMetrics(compact || square, controlSize)
        // Disabled: text3 and no fill. Under the pointer: the ground's hover fill. Pressed: G.Hover.pressed.
        let active = enabled && (hover || configuration.isPressed)
        let fill: Color = !enabled ? .clear : G.Hover.item(hover: hover, pressed: configuration.isPressed, on: ground)
        let height = size ?? m.height
        let radius = height > G.Height.control28 ? G.Radius.r8 : G.Radius.r6
        // Only an icon-only square of 28 or more draws its symbol at 16.
        let icon = square && height >= G.Height.control28 ? G.Icon.md : m.icon
        configuration.label
            .lineLimit(1)
            .textStyle(.body)
            .labelStyle(ButtonLabelStyle(icon: icon, weight: .regular))
            .foregroundStyle(!enabled ? G.text3 : (active ? G.text : G.text2))
            .padding(.horizontal, square ? 0 : G.Space.s8)
            .frame(maxWidth: wide ? .infinity : nil, alignment: .leading)
            .frame(width: square ? height : nil, height: height)
            .background(fill, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .focusRing(radius)
            .onHover { hover = $0 }
    }

    public init(compact: Bool = false, square: Bool = false, size: CGFloat? = nil, wide: Bool = false) {
        self.compact = compact
        self.square = square
        self.size = size
        self.wide = wide
    }
}

public extension ButtonStyle where Self == PrimaryButtonStyle { static var primary: PrimaryButtonStyle { .init() } }
public extension ButtonStyle where Self == SecondaryButtonStyle { static var secondary: SecondaryButtonStyle { .init() } }
public extension ButtonStyle where Self == GhostButtonStyle { static var ghost: GhostButtonStyle { .init() } }
#endif
