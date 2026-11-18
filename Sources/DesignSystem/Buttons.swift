import SwiftUI

// MARK: Buttons: 32 standard, 28 compact (toolbars, cards, table rows)

/// The size of a button: compact when asked, or under `.controlSize(.small)`.
private struct ButtonMetrics {
    let compact: Bool
    init(_ compact: Bool, _ controlSize: ControlSize) {
        self.compact = compact || controlSize == .small || controlSize == .mini
    }
    var height: CGFloat { compact ? K.Height.control28 : K.Height.control32 }
    var radius: CGFloat { compact ? K.Radius.r6 : K.Radius.r8 }
    /// The symbol beside a button's title is 12 at both sizes (design system: Button).
    var icon: CGFloat { K.Icon.i12 }
}

/// A Label inside a button: the icon on the icon scale, 8 before its title.
struct ButtonLabelStyle: LabelStyle {
    var icon: CGFloat
    var weight: Font.Weight
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: K.Space.s8) {
            configuration.icon.font(.system(size: K.Icon.point(icon), weight: weight))
            configuration.title
        }
    }
}

/// "⌘N": a 16-point badge with the shortcut in `small`.
struct ShortcutBadge: View {
    let text: String
    var onPrimary = false
    var body: some View {
        Text(text).textStyle(.small)
            .padding(.horizontal, K.Space.s4)
            .frame(height: K.Height.control16)
            .background(onPrimary ? K.onPrimary.opacity(K.Opacity.kbd) : .clear, in: RoundedRectangle(cornerRadius: K.Radius.r4))
            .overlay {
                if !onPrimary { RoundedRectangle(cornerRadius: K.Radius.r4).strokeBorder(K.border) }
            }
    }
}

/// The main button: black in light mode, white in dark, with an optional shortcut badge.
struct PrimaryButtonStyle: ButtonStyle {
    var shortcut: String? = nil
    var wide = false
    var compact = false
    @Environment(\.isEnabled) private var enabled
    @Environment(\.controlSize) private var controlSize
    @State private var hover = false
    func makeBody(configuration: Configuration) -> some View {
        let m = ButtonMetrics(compact, controlSize)
        // primary at rest, then primaryHover and primaryPressed (opaque, so the ground never shows through);
        // 30% when disabled.
        let fill: Color = !enabled ? K.primary.opacity(K.Opacity.disabled)
            : (configuration.isPressed ? K.primaryPressed : (hover ? K.primaryHover : K.primary))
        HStack(spacing: K.Space.s8) {
            configuration.label.lineLimit(1)
            if let shortcut { ShortcutBadge(text: shortcut, onPrimary: true) }
        }
        .textStyle(.bodyStrong)
        .labelStyle(ButtonLabelStyle(icon: m.icon, weight: .semibold))
        .foregroundStyle(K.onPrimary)
        .padding(.horizontal, K.Space.s12)
        .frame(height: m.height)
        .frame(maxWidth: wide ? .infinity : nil)
        .background(fill, in: RoundedRectangle(cornerRadius: m.radius, style: .continuous))
        // The secondary's shadow: a bigger one made the primary look taller beside it (EmptyState review).
        .shadow(enabled ? K.Shadow.control : K.Shadow.none)
        .focusRing(m.radius)
        .onHover { hover = $0 }
    }
}

/// A white raised button with a hairline border, as for "Update now".
struct SecondaryButtonStyle: ButtonStyle {
    var compact = false
    @Environment(\.isEnabled) private var enabled
    @Environment(\.controlSize) private var controlSize
    @State private var hover = false
    func makeBody(configuration: Configuration) -> some View {
        let m = ButtonMetrics(compact, controlSize)
        configuration.label
            .lineLimit(1)
            .textStyle(.bodyMedium)
            .labelStyle(ButtonLabelStyle(icon: m.icon, weight: .medium))
            // A destructive one (Remove…) keeps the secondary frame with danger text (PageEditTarget).
            .foregroundStyle(!enabled ? K.text3 : configuration.role == .destructive ? K.danger : K.text)
            .padding(.horizontal, K.Space.s12)
            .frame(height: m.height)
            // card, cardHover under the pointer, K.Hover.pressed while pressed. A destructive one hovers the same.
            .background(configuration.isPressed ? K.Hover.pressed : (hover ? K.cardHover : K.card),
                        in: RoundedRectangle(cornerRadius: m.radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: m.radius, style: .continuous).strokeBorder(K.border))
            .shadow(K.Shadow.control)
            .focusRing(m.radius)
            .onHover { hover = $0 }
    }
}

/// Text that gains a fill under the pointer. `square` makes an icon-only button as wide as it is
/// high; `size` sets that side (24 inside rows); `wide` fills the width, as a menu row.
struct GhostButtonStyle: ButtonStyle {
    var compact = false
    var square = false
    var size: CGFloat? = nil
    var wide = false
    @Environment(\.isEnabled) private var enabled
    @Environment(\.controlSize) private var controlSize
    @Environment(\.hoverGround) private var ground
    @State private var hover = false
    func makeBody(configuration: Configuration) -> some View {
        let m = ButtonMetrics(compact || square, controlSize)
        // Disabled: text3 and no fill. Under the pointer: the ground's hover fill. Pressed: K.Hover.pressed.
        let active = enabled && (hover || configuration.isPressed)
        let fill: Color = !enabled ? .clear : K.Hover.item(hover: hover, pressed: configuration.isPressed, on: ground)
        let height = size ?? m.height
        let radius = height > K.Height.control28 ? K.Radius.r8 : K.Radius.r6
        // Only an icon-only square of 28 or more draws its symbol at 16.
        let icon = square && height >= K.Height.control28 ? K.Icon.i16 : m.icon
        configuration.label
            .lineLimit(1)
            .textStyle(.body)
            .labelStyle(ButtonLabelStyle(icon: icon, weight: .regular))
            .foregroundStyle(!enabled ? K.text3 : (active ? K.text : K.text2))
            .padding(.horizontal, square ? 0 : K.Space.s8)
            .frame(maxWidth: wide ? .infinity : nil, alignment: .leading)
            .frame(width: square ? height : nil, height: height)
            .background(fill, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .focusRing(radius)
            .onHover { hover = $0 }
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle { static var primary: PrimaryButtonStyle { .init() } }
extension ButtonStyle where Self == SecondaryButtonStyle { static var secondary: SecondaryButtonStyle { .init() } }
extension ButtonStyle where Self == GhostButtonStyle { static var ghost: GhostButtonStyle { .init() } }
