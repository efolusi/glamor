import SwiftUI

// MARK: Fields: 32 standard, 28 compact (toolbars, side panels)

/// An input with a focus ring in the accent colour.
struct FieldBox<Content: View>: View {
    var focused = false
    var compact = false
    @ViewBuilder var content: () -> Content
    var body: some View {
        let radius = compact ? K.Radius.r6 : K.Radius.r8
        content()
            .textFieldStyle(.plain)
            .padding(.horizontal, compact ? K.Space.s8 : K.Space.s12)
            .frame(height: compact ? K.Height.control28 : K.Height.control32)
            .background(K.field, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(focused ? K.accent.opacity(K.Opacity.ring) : K.controlEdge, lineWidth: focused ? K.Line.strong : K.Line.hair))
    }
}

/// A labelled form field: label above, help below.
struct FormField<Content: View>: View {
    let label: String
    var help: String = ""
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: K.Space.s8) {
            Text(label).textStyle(.bodyMedium).foregroundStyle(K.text)
            content()
            if !help.isEmpty {
                Text(help).textStyle(.caption).foregroundStyle(K.text3).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct TextFieldBox: View {
    let placeholder: String
    @Binding var text: String
    var mono = false
    var secure = false
    var compact = false
    /// What VoiceOver names the field; without it, the placeholder.
    var label: String?
    @FocusState private var focused: Bool
    var body: some View {
        FieldBox(focused: focused, compact: compact) {
            Group {
                if secure { SecureField(placeholder, text: $text) } else { TextField(placeholder, text: $text) }
            }
            .textStyle(mono ? .monoL : .body)
            .focused($focused)
            .accessibilityLabel(label ?? placeholder)
        }
    }
}

/// A bordered card with a title, a line of help and a switch, as for "Reach through a server or VPN".
struct ToggleCard<Extra: View>: View {
    let title: String
    let help: String
    @Binding var isOn: Bool
    @ViewBuilder var extra: () -> Extra
    var body: some View {
        VStack(alignment: .leading, spacing: K.Space.s12) {
            HStack(alignment: .center, spacing: K.Space.s12) {
                VStack(alignment: .leading, spacing: K.Space.s2) {
                    Text(title).textStyle(.bodyMedium).foregroundStyle(K.text)
                    Text(help).textStyle(.caption).foregroundStyle(K.text2)
                }
                Spacer()
                Toggle(title, isOn: $isOn).toggleStyle(.switch).labelsHidden().controlSize(.small)
                    .accessibilityHint(help)
            }
            if isOn { extra() }
        }
        .card(padding: K.Space.s16)
    }
}

extension ToggleCard where Extra == EmptyView {
    init(title: String, help: String, isOn: Binding<Bool>) {
        self.init(title: title, help: help, isOn: isOn) { EmptyView() }
    }
}

/// Tabs drawn as words with a line under the chosen one; 28 high.
struct UnderlineTabs<T: Hashable>: View {
    let items: [(T, String)]
    @Binding var selection: T
    var body: some View {
        HStack(spacing: K.Space.s24) {
            ForEach(items, id: \.0) { value, title in
                UnderlineTab(title: title, selected: selection == value) { selection = value }
            }
        }
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
            VStack(spacing: K.Space.s8) {
                Text(title)
                    .textStyle(.body)  // one weight: a bold choice changed the tab's width
                    .foregroundStyle(selected || hover ? K.text : K.text2)
                    .frame(height: K.Height.line16)
                Rectangle().fill(selected ? K.text : (hover ? K.borderFill : .clear)).frame(height: K.Line.strong)
            }
            .fixedSize()
            .frame(height: K.Height.control28, alignment: .bottom)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plainFocus())
        .onHover { hover = $0 }
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct Pill: View {
    let text: String
    var color: Color = K.text2
    @Environment(\.colorSchemeContrast) private var contrast
    var body: some View {
        Text(text).textStyle(.small).lineLimit(1)
            .padding(.horizontal, K.Space.s8)
            .frame(height: K.Height.pill)
            .foregroundStyle(color)
            // The tint sits on an opaque card ground, so a hovered row or a subtle panel never shows
            // through. At the 10% pill tint every status color holds 4.6:1 or more on it in both themes; with
            // Increase contrast the tint is 16% and the status colors take their increased pair: 4.61:1 or more.
            .background(color.opacity(K.Opacity.pill(contrast)), in: Capsule())
            .background(K.card, in: Capsule())
    }
}

/// A page section's title, an optional line under it, and an optional link on the right.
struct SectionTitle: View {
    let title: String
    var detail: String?
    var subtitle: String?
    init(_ title: String, detail: String? = nil, subtitle: String? = nil) {
        self.title = title; self.detail = detail; self.subtitle = subtitle
    }
    var body: some View {
        VStack(alignment: .leading, spacing: K.Space.s4) {
            HStack(alignment: .firstTextBaseline, spacing: K.Space.s8) {
                Text(title).textStyle(.titleS).foregroundStyle(K.text).accessibilityAddTraits(.isHeader)
                if let detail { Text(detail).textStyle(.body).monospacedDigit().foregroundStyle(K.text3) }
            }
            if let subtitle { Text(subtitle).textStyle(.body).foregroundStyle(K.text2) }
        }
    }
}

/// "View all 4 ›": body in text2 with an 8 bold chevron 4 after it, text under the pointer.
struct LinkButton: View {
    let title: String
    let action: () -> Void
    @State private var hover = false
    var body: some View {
        Button(action: action) {
            HStack(spacing: K.Space.s4) { Text(title); Image(systemName: "chevron.right").icon(K.Icon.i8, weight: .bold) }
                .textStyle(.body).foregroundStyle(hover ? K.text : K.text2)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plainFocus())
        .onHover { hover = $0 }
    }
}

/// The search line on top of a page, 40 high, with an optional compact action on the right (Connect)
/// or other compact (28) controls in `accessory`.
struct SearchBar<Accessory: View>: View {
    let placeholder: String
    @Binding var text: String
    var actionTitle: String?
    var action: (() -> Void)?
    @ViewBuilder var accessory: () -> Accessory
    @FocusState private var focused: Bool

    init(placeholder: String, text: Binding<String>, actionTitle: String? = nil, action: (() -> Void)? = nil,
         @ViewBuilder accessory: @escaping () -> Accessory) {
        self.placeholder = placeholder; _text = text; self.actionTitle = actionTitle; self.action = action
        self.accessory = accessory
    }

    var body: some View {
        HStack(spacing: K.Space.s8) {
            Image(systemName: "magnifyingglass").icon(K.Icon.i16).foregroundStyle(K.text3)
                .accessibilityHidden(true)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .textStyle(.body)
                .focused($focused)
                .onSubmit { action?() }
            if !text.isEmpty {
                Button { text = "" } label: { Image(systemName: "xmark.circle.fill").icon(K.Icon.i16) }
                    .buttonStyle(.plainFocus(K.Radius.r4)).foregroundStyle(K.text3)
                    .help("Clear the search")
                    .accessibilityLabel("Clear the search")
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action).buttonStyle(SecondaryButtonStyle(compact: true)).disabled(text.isEmpty)
            }
            accessory().controlSize(.small)
        }
        .padding(.leading, K.Space.s12)
        .padding(.trailing, actionTitle == nil && Accessory.self == EmptyView.self ? K.Space.s12 : K.Space.s4)
        .frame(height: K.Height.control40)
        .background(K.field, in: RoundedRectangle(cornerRadius: K.Radius.r12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: K.Radius.r12, style: .continuous)
            .strokeBorder(focused ? K.accent.opacity(K.Opacity.ring) : K.controlEdge, lineWidth: focused ? K.Line.strong : K.Line.hair))
    }
}

extension SearchBar where Accessory == EmptyView {
    init(placeholder: String, text: Binding<String>, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.init(placeholder: placeholder, text: text, actionTitle: actionTitle, action: action) { EmptyView() }
    }
}

/// A choice from a list, drawn as a secondary button (32, or 28 when compact) so it matches the buttons
/// beside it. The system menu opens it, with the same Picker inside.
struct MenuPicker<Value: Hashable, Options: View>: View {
    let title: String
    @Binding var selection: Value
    var compact = false
    @ViewBuilder var options: () -> Options
    @Environment(\.controlSize) private var controlSize
    @State private var hover = false
    var body: some View {
        let small = compact || controlSize == .small || controlSize == .mini
        let radius = small ? K.Radius.r6 : K.Radius.r8
        Menu {
            Picker(title, selection: $selection) { options() }.pickerStyle(.inline).labelsHidden()
        } label: {
            Text(title).textStyle(.bodyMedium).foregroundStyle(K.text)
        }
        .menuStyle(.borderlessButton)
        .tint(K.text)    // a secondary control: text, not the accent (PageAuditLog)
        .fixedSize()
        .padding(.horizontal, K.Space.s12)
        .frame(height: small ? K.Height.control28 : K.Height.control32)
        // The secondary button's hover, as it is drawn like one.
        .background(hover ? K.cardHover : K.card, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(K.border))
        .shadow(K.Shadow.control)
        .onHover { hover = $0 }
    }
}

/// Segmented: a 28 track on `subtle` with 24 segments. The chosen one is raised (`card`, a hairline and
/// K.Shadow.control); the others turn `text` under the pointer. One weight for every segment, so choosing one
/// never changes its width. `fill` stretches the track and makes the segments equal (a card's list head).
/// Tab reaches each segment, Space chooses, ← → move; VoiceOver reads the chosen one as selected.
struct SegmentedControl: View {
    let items: [String]
    @Binding var selection: Int
    var fill = false

    var body: some View {
        HStack(spacing: K.Space.s2) {
            ForEach(items.indices, id: \.self) { i in
                SegmentItem(title: items[i], on: selection == i, fill: fill) { selection = i }
            }
        }
        .padding(.horizontal, K.Space.s2)
        .frame(maxWidth: fill ? .infinity : nil)
        .frame(height: K.Height.control28)
        .background(K.subtle, in: RoundedRectangle(cornerRadius: K.Radius.r8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: K.Radius.r8, style: .continuous).strokeBorder(K.border, lineWidth: K.Line.hair))
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
}

private struct SegmentItem: View {
    let title: String
    let on: Bool
    let fill: Bool
    let action: () -> Void
    @State private var hover = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: K.Radius.r6, style: .continuous)
        Button(action: action) {
            Text(title)
                .textStyle(.caption)
                .foregroundStyle(on || hover ? K.text : K.text2)
                .padding(.horizontal, K.Space.s8)
                .frame(maxWidth: fill ? .infinity : nil, minHeight: K.Height.control24, alignment: .leading)
                .background {
                    if on { shape.fill(K.card).overlay(shape.strokeBorder(K.border, lineWidth: K.Line.hair)).shadow(K.Shadow.control) }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plainFocus(K.Radius.r6))
        .onHover { hover = $0 }
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}
