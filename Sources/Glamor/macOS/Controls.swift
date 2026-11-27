#if os(macOS)
import SwiftUI

// MARK: Fields: 32 standard, 28 compact (toolbars, side panels)

/// An input with a focus ring in the accent colour.
public struct FieldBox<Content: View>: View {
    public var focused: Bool = false
    public var compact: Bool = false
    @ViewBuilder public var content: () -> Content
    public var body: some View {
        let radius = compact ? G.Radius.r6 : G.Radius.r8
        content()
            .textFieldStyle(.plain)
            .padding(.horizontal, compact ? G.Space.s8 : G.Space.s12)
            .frame(height: compact ? G.Height.control28 : G.Height.control32)
            .background(G.field, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(focused ? G.focus.opacity(G.Opacity.ring) : G.controlEdge, lineWidth: focused ? G.Line.strong : G.Line.hair))
    }

    public init(focused: Bool = false, compact: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.focused = focused
        self.compact = compact
        self.content = content
    }
}

/// A labelled form field: label above, help below.
public struct FormField<Content: View>: View {
    public let label: String
    public var help: String = ""
    @ViewBuilder public var content: () -> Content
    public var body: some View {
        VStack(alignment: .leading, spacing: G.Space.s8) {
            Text(label).textStyle(.bodyMedium).foregroundStyle(G.text)
            content()
            if !help.isEmpty {
                Text(help).textStyle(.caption).foregroundStyle(G.text3).fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    public init(label: String, help: String = "", @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.help = help
        self.content = content
    }
}

public struct TextFieldBox: View {
    public let placeholder: String
    @Binding public var text: String
    public var mono: Bool = false
    public var secure: Bool = false
    public var compact: Bool = false
    /// What VoiceOver names the field.
    public let label: String
    @FocusState private var focused: Bool
    public var body: some View {
        FieldBox(focused: focused, compact: compact) {
            Group {
                if secure { SecureField(placeholder, text: $text) } else { TextField(placeholder, text: $text) }
            }
            .textStyle(mono ? .monoL : .body)
            .focused($focused)
            .accessibilityLabel(label)
        }
    }

    public init(placeholder: String, text: Binding<String>, mono: Bool = false, secure: Bool = false, compact: Bool = false, label: String) {
        self.placeholder = placeholder
        self._text = text
        self.mono = mono
        self.secure = secure
        self.compact = compact
        self.label = label
    }
}

/// A bordered card with a title, a line of help and a switch, as for "Reach through a server or VPN".
/// The switch is the system `Toggle`, tinted with `G.accentEdge` so its on state is the same copper edge as the web
/// switch (3:1 or more on a card in light, dark and Increase contrast; plain copper is 2.7:1 on a light card). A
/// `Toggle` you draw yourself takes the app's `AccentColor`: do not set that to copper, tint it with `G.accentEdge`.
public struct ToggleCard<Extra: View>: View {
    public let title: String
    public let help: String
    @Binding public var isOn: Bool
    @ViewBuilder public var extra: () -> Extra
    public var body: some View {
        VStack(alignment: .leading, spacing: G.Space.s12) {
            HStack(alignment: .center, spacing: G.Space.s12) {
                VStack(alignment: .leading, spacing: G.Space.s2) {
                    Text(title).textStyle(.bodyMedium).foregroundStyle(G.text)
                    Text(help).textStyle(.caption).foregroundStyle(G.text2)
                }
                Spacer()
                Toggle(title, isOn: $isOn).toggleStyle(.switch).labelsHidden().controlSize(.small)
                    .tint(G.accentEdge)
                    .accessibilityHint(help)
            }
            if isOn { extra() }
        }
        .card(padding: G.Space.s16)
    }

    public init(title: String, help: String, isOn: Binding<Bool>, @ViewBuilder extra: @escaping () -> Extra) {
        self.title = title
        self.help = help
        self._isOn = isOn
        self.extra = extra
    }
}

public extension ToggleCard where Extra == EmptyView {
    init(title: String, help: String, isOn: Binding<Bool>) {
        self.init(title: title, help: help, isOn: isOn) { EmptyView() }
    }
}

/// Tabs drawn as words with a line under the chosen one; 28 high.
public struct UnderlineTabs<T: Hashable>: View {
    public let items: [(T, String)]
    @Binding public var selection: T
    public var body: some View {
        HStack(spacing: G.Space.s24) {
            ForEach(items, id: \.0) { value, title in
                UnderlineTab(title: title, selected: selection == value) { selection = value }
            }
        }
    }

    public init(items: [(T, String)], selection: Binding<T>) {
        self.items = items
        self._selection = selection
    }
}

/// One underline tab: the chosen one has a text line under it; under the pointer, the others turn
/// to text with a border line, so hover never looks like the choice.
private struct UnderlineTab: View {
    let title: String
    let selected: Bool
    let action: () -> Void
    @State private var hover = false
    var body: some View {
        Button(action: action) {
            VStack(spacing: G.Space.s8) {
                Text(title)
                    .textStyle(.body)  // one weight: a bold choice changed the tab's width
                    .foregroundStyle(selected || hover ? G.text : G.text2)
                    .frame(height: G.Height.line16)
                Rectangle().fill(selected ? G.text : (hover ? G.borderFill : .clear)).frame(height: G.Line.strong)
            }
            .fixedSize()
            .frame(height: G.Height.control28, alignment: .bottom)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plainFocus())
        .onHover { hover = $0 }
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

public struct Pill: View {
    public let text: String
    public var color: Color = G.text2
    @Environment(\.colorSchemeContrast) private var contrast
    public var body: some View {
        Text(text).textStyle(.small).lineLimit(1)
            .padding(.horizontal, G.Space.s8)
            .frame(height: G.Height.pill)
            .foregroundStyle(color)
            // The tint sits on an opaque card ground, so a hovered row or a subtle panel never shows
            // through. At the 10% pill tint every status color holds 4.6:1 or more on it in both themes; with
            // Increase contrast the tint is 16% and the status colors take their increased pair: 4.61:1 or more.
            .background(color.opacity(G.Opacity.pill(contrast)), in: Capsule())
            .background(G.card, in: Capsule())
    }

    public init(text: String, color: Color = G.text2) {
        self.text = text
        self.color = color
    }
}

/// A page section's title, an optional line under it, and an optional link on the right.
public struct SectionTitle: View {
    public let title: String
    public var detail: String?
    public var subtitle: String?
    public init(_ title: String, detail: String? = nil, subtitle: String? = nil) {
        self.title = title; self.detail = detail; self.subtitle = subtitle
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: G.Space.s4) {
            HStack(alignment: .firstTextBaseline, spacing: G.Space.s8) {
                Text(title).textStyle(.titleS).foregroundStyle(G.text).accessibilityAddTraits(.isHeader)
                if let detail { Text(detail).textStyle(.body).monospacedDigit().foregroundStyle(G.text3) }
            }
            if let subtitle { Text(subtitle).textStyle(.body).foregroundStyle(G.text2) }
        }
    }
}

/// "View all 4 ›": body in text2 with an 8 bold chevron `G.Space.labelIcon` after it, text under the pointer.
public struct LinkButton: View {
    public let title: String
    public let action: () -> Void
    @State private var hover = false
    public var body: some View {
        Button(action: action) {
            HStack(spacing: G.Space.labelIcon) { Text(title); Image(systemName: "chevron.right").icon(G.Icon.xs, weight: .bold) }
                .textStyle(.body).foregroundStyle(hover ? G.text : G.text2)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plainFocus())
        .onHover { hover = $0 }
    }

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

/// The search line on top of a page, 40 high, with an optional compact action on the right (Connect)
/// or other compact (28) controls in `accessory`.
/// On glass its edge is promised 3:1 against the surface tokens only; over photos, video or pure black or white
/// content the caller puts a scrim behind it.
public struct SearchBar<Accessory: View>: View {
    public let placeholder: String
    @Binding public var text: String
    public var actionTitle: String?
    public var action: (() -> Void)?
    @ViewBuilder public var accessory: () -> Accessory
    @FocusState private var focused: Bool

    public init(placeholder: String, text: Binding<String>, actionTitle: String? = nil, action: (() -> Void)? = nil,
         @ViewBuilder accessory: @escaping () -> Accessory) {
        self.placeholder = placeholder; _text = text; self.actionTitle = actionTitle; self.action = action
        self.accessory = accessory
    }

    public var body: some View {
        HStack(spacing: G.Space.labelIcon) {
            Image(systemName: "magnifyingglass").icon(G.Icon.md).foregroundStyle(G.text3)
                .accessibilityHidden(true)
            // The placeholder is drawn in G.placeholder: the system's colour is nearly invisible on glass (GL18).
            // The label keeps the same words for VoiceOver.
            TextField(text: $text, prompt: Text(placeholder).foregroundStyle(G.placeholder)) { Text(placeholder) }
                .textFieldStyle(.plain)
                .textStyle(.body)
                .accessibilityLabel(placeholder)
                .focused($focused)
                .onSubmit { action?() }
            if !text.isEmpty {
                Button { text = "" } label: { Image(systemName: "xmark.circle.fill").icon(G.Icon.md) }
                    .buttonStyle(.plainFocus(G.Radius.r4)).foregroundStyle(G.text3)
                    .help(GlamorText.string(.clearSearch))
                    .accessibilityLabel(GlamorText.string(.clearSearch))
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action).buttonStyle(SecondaryButtonStyle(compact: true)).disabled(text.isEmpty)
            }
            accessory().controlSize(.small)
        }
        .padding(.leading, G.Space.s12)
        .padding(.trailing, actionTitle == nil && Accessory.self == EmptyView.self ? G.Space.s12 : G.Space.s4)
        .frame(height: G.Height.control40)
        .glassSurface(in: RoundedRectangle(cornerRadius: G.Radius.r12, style: .continuous), fill: G.field, edge: G.controlEdge, edgeOnGlass: true)
        .overlay {
            if focused {
                RoundedRectangle(cornerRadius: G.Radius.r12, style: .continuous)
                    .strokeBorder(G.focus.opacity(G.Opacity.ring), lineWidth: G.Line.strong)
            }
        }
    }
}

public extension SearchBar where Accessory == EmptyView {
    init(placeholder: String, text: Binding<String>, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.init(placeholder: placeholder, text: text, actionTitle: actionTitle, action: action) { EmptyView() }
    }
}

/// A choice from a list, drawn as a secondary button (32, or 28 when compact, a capsule) so it matches the buttons
/// beside it. The system menu opens it, with the same Picker inside.
public struct MenuPicker<Value: Hashable, Options: View>: View {
    public let title: String
    @Binding public var selection: Value
    public var compact: Bool = false
    @ViewBuilder public var options: () -> Options
    @Environment(\.controlSize) private var controlSize
    @State private var hover = false
    @State private var face = CGSize.zero
    @FocusState private var focused: Bool
    public var body: some View {
        let small = compact || controlSize == .small || controlSize == .mini
        let shape = Capsule()
        // The face is drawn here, outside the Menu: the system re-lays out a Menu's label (it put the chevron
        // first, 7 pt from the word), so the label is an empty rectangle of the face's size and the Menu covers
        // the whole face: that is its hit and accessibility area (GL21).
        HStack(spacing: G.Space.labelIcon) {
            Text(title).textStyle(.bodyMedium).foregroundStyle(G.text)
            Image(systemName: "chevron.down").icon(G.Icon.xs, weight: .bold).foregroundStyle(G.text2)
        }
        .accessibilityHidden(true)
        .padding(.horizontal, G.Space.s12)
        .frame(height: small ? G.Height.control28 : G.Height.control32)
        // The secondary button's hover, as it is drawn like one.
        .background(hover ? G.cardHover : G.card, in: shape)
        .overlay(shape.strokeBorder(G.border))
        .shadow(G.Shadow.control)
        .onGeometryChange(for: CGSize.self, of: \.size) { face = $0 }
        .overlay {
            Menu {
                Picker(title, selection: $selection) { options() }.pickerStyle(.inline).labelsHidden()
            } label: { Color.clear }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .tint(G.text)    // a secondary control: text, not the accent (PageAuditLog)
                .fixedSize()
                .frame(width: face.width, height: face.height)
                .contentShape(shape)
                .accessibilityLabel(title)
                .focused($focused)
        }
        .focusRingCapsule(isFocused: focused)
        .onHover { hover = $0 }
    }

    public init(title: String, selection: Binding<Value>, compact: Bool = false, @ViewBuilder options: @escaping () -> Options) {
        self.title = title
        self._selection = selection
        self.compact = compact
        self.options = options
    }
}

/// Segmented: a 28 track on `subtle` with 24 segments. The chosen one is raised (`card`, a hairline and
/// G.Shadow.control); the others turn `text` under the pointer. One weight for every segment, so choosing one
/// never changes its width. `fill` stretches the track and makes the segments equal (a card's list head).
/// Tab reaches each segment, Space chooses, ← → move; VoiceOver reads the chosen one as selected.
public struct SegmentedControl: View {
    public let items: [String]
    @Binding public var selection: Int
    public var fill: Bool = false

    public var body: some View {
        HStack(spacing: G.Space.s2) {
            ForEach(items.indices, id: \.self) { i in
                SegmentItem(title: items[i], on: selection == i, fill: fill) { selection = i }
            }
        }
        .padding(.horizontal, G.Space.s2)
        .frame(maxWidth: fill ? .infinity : nil)
        .frame(height: G.Height.control28)
        .glassSurface(in: RoundedRectangle(cornerRadius: G.Radius.r8, style: .continuous), tinted: false, fill: G.subtle, edge: G.border)
        .fixedSize(horizontal: !fill, vertical: false)
        .onKeyPress(.leftArrow) { move(-1) }
        .onKeyPress(.rightArrow) { move(1) }
        .accessibilityElement(children: .contain)
    }

    private func move(_ by: Int) -> KeyPress.Result {
        let next = selection + by
        guard items.indices.contains(next) else { return .ignored }
        selection = next
        return .handled
    }

    public init(items: [String], selection: Binding<Int>, fill: Bool = false) {
        self.items = items
        self._selection = selection
        self.fill = fill
    }
}

private struct SegmentItem: View {
    let title: String
    let on: Bool
    let fill: Bool
    let action: () -> Void
    @State private var hover = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: G.Radius.r6, style: .continuous)
        Button(action: action) {
            Text(title)
                .textStyle(.caption)
                .foregroundStyle(on || hover ? G.text : G.text2)
                .padding(.horizontal, G.Space.s8)
                .frame(maxWidth: fill ? .infinity : nil, minHeight: G.Height.control24, alignment: .leading)
                .background {
                    // Always solid: the track is the glass, and glass is never inside glass (design-tokens glass.md).
                    if on { shape.fill(G.card).overlay(shape.strokeBorder(G.border, lineWidth: G.Line.hair)).shadow(G.Shadow.control) }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plainFocus(G.Radius.r6))
        .onHover { hover = $0 }
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}
#endif
