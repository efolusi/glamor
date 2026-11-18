import SwiftUI

// Lists before cards (Layout rules): inventories are one-line rows in a card, filtered by chips.

/// Rows in one card, with hairlines between them.
struct CardList<Content: View>: View {
    var inset: CGFloat = K.Space.s16
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(spacing: 0) {
            Group(subviews: content()) { subviews in
                ForEach(Array(subviews.enumerated()), id: \.offset) { i, v in
                    v
                    if i < subviews.count - 1 { Hairline(color: K.border.opacity(K.Opacity.softHairline)).padding(.leading, inset) }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: K.radius, style: .continuous))
        .card()
    }
}

/// A label on the left, its value on the right: 40 high.
struct InfoRow<Value: View>: View {
    let label: String
    @ViewBuilder var value: () -> Value
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(label).foregroundStyle(K.text2)
            Spacer(minLength: K.Space.s20)
            value().foregroundStyle(K.text).multilineTextAlignment(.trailing).textSelection(.enabled)
        }
        .textStyle(.body)
        .padding(.horizontal, K.Space.s16)
        .padding(.vertical, K.Space.s4)       // only matters when a value wraps
        .frame(minHeight: K.Height.row40)
    }
}

extension InfoRow where Value == Text {
    init(_ label: String, _ value: String) { self.init(label: label) { Text(value) } }
}

// MARK: Selectable rows (design system: ListRow)
//
// One spec for every list a person picks from (K.Row): the highlight sits 8 in from a side list's
// edge (4 in a card), 2 apart from the next row, with 8 corners; the text starts 12 inside it, so it
// stays at the same place at rest, under the pointer, selected and focused. Under the pointer the row takes
// the hover fill of its ground (K.Hover: onCard in a card, onPanel in a side list); pressed, K.Hover.pressed;
// selected, `accent` at 10% with the selected-marker; focused, the 2-pt `focus` ring on the highlight's own shape.

/// The highlight behind a selectable row. Use `.buttonStyle(.row(...))` for a row that is a Button; use
/// this for a row that handles its own clicks (a double click, a drag).
struct RowHighlight: ViewModifier {
    var selected = false
    var hover = false
    var pressed = false
    /// Debug galleries only: draw the focus ring without keyboard focus.
    var showFocus = false
    @Environment(\.isFocused) private var isFocused
    @Environment(\.hoverGround) private var ground

    func body(content: Content) -> some View {
        let focused = isFocused || showFocus
        let shape = RoundedRectangle(cornerRadius: K.Row.radius, style: .continuous)
        content
            .background(selected ? K.accent.opacity(K.Opacity.selected)
                        : K.Hover.item(hover: hover, pressed: pressed, on: ground), in: shape)
            .overlay { if focused { shape.strokeBorder(K.focus, lineWidth: K.Line.strong).allowsHitTesting(false) } }
            .selectedMarker(selected)
            .focusEffectDisabled()
    }
}

extension View {
    /// The ListRow highlight: the ground's hover fill under the pointer, `accent` at 10% and the marker when selected.
    func rowHighlight(selected: Bool = false, hover: Bool = false) -> some View {
        modifier(RowHighlight(selected: selected, hover: hover))
    }

    /// A ListRow's look for a debug gallery: padding, height and highlight, with the focus ring forced.
    func rowLook(selected: Bool = false, hover: Bool = false, focus: Bool = false, height: CGFloat = K.Row.oneLine) -> some View {
        padding(.horizontal, K.Row.padding)
            .frame(maxWidth: .infinity, minHeight: height, alignment: .leading)
            .modifier(RowHighlight(selected: selected, hover: hover, showFocus: focus))
    }
}

/// A row a person clicks to pick or open something: K.Row.padding inside, at least `height` high
/// (32 for one line, 52 for a name over a line of help), with the ListRow highlight. The label lays out
/// its own content; the style adds the padding, the highlight, the focus ring and the selected trait.
struct RowStyle: ButtonStyle {
    var selected = false
    var height: CGFloat = K.Row.oneLine
    @State private var hover = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, K.Row.padding)
            .frame(maxWidth: .infinity, minHeight: height, alignment: .leading)
            .contentShape(Rectangle())
            .modifier(RowHighlight(selected: selected, hover: hover, pressed: configuration.isPressed))
            .onHover { hover = $0 }
            .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

extension ButtonStyle where Self == RowStyle {
    /// A ListRow: `.buttonStyle(.row(selected: picked == item))`, `height: K.Row.twoLine` for two lines.
    static func row(selected: Bool = false, height: CGFloat = K.Row.oneLine) -> RowStyle {
        RowStyle(selected: selected, height: height)
    }
}

/// A side list's rows (Recipes, the schema, collections, cache keys): K.Row.listInset from every edge
/// and K.Row.gap between rows. Put it inside the ScrollView.
struct SideListStack<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        LazyVStack(alignment: .leading, spacing: K.Row.gap) { content() }
            .padding(K.Row.listInset)
    }
}

/// A group's name in a side list, in line with the rows' text (listInset + padding = 20 from the edge).
struct ListSectionLabel: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title.uppercased()).textStyle(.sectionLabel).tracking(K.Font.sectionTracking).foregroundStyle(K.text3)
            .frame(height: K.Height.line16)
            .padding(.horizontal, K.Row.padding).padding(.top, K.Space.s12).padding(.bottom, K.Space.s4)
            .accessibilityAddTraits(.isHeader)
    }
}

/// "PRODUCTION": a group's name above a card of rows, inset 16 so it lines up with the names in the card.
struct CardSectionLabel: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title.uppercased()).textStyle(.sectionLabel).tracking(K.Font.sectionTracking).foregroundStyle(K.text3)
            .padding(.horizontal, K.Space.s16)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A clickable row in a CardList: the highlight K.Row.cardInset in from the card on every side, the
/// text 16 from the card's edge (where the hairlines start). 40 high unless the content is taller.
struct ListRow<Content: View>: View {
    var height: CGFloat = K.Height.row40
    var selected = false
    let action: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        Button(action: action) {
            HStack(spacing: K.Space.s12) { content() }
        }
        .buttonStyle(.row(selected: selected, height: height - 2 * K.Row.cardInset))
        .padding(K.Row.cardInset)
    }
}

/// A rounded word that is either chosen or not, like a filter chip (design system: Chip). Only the chosen
/// one has the ring, so a chip under the pointer never looks chosen.
struct ChipStyle: ButtonStyle {
    let selected: Bool
    @State private var hover = false
    @Environment(\.hoverGround) private var ground
    func makeBody(configuration: Configuration) -> some View {
        let fill: Color = selected ? K.cardHover
            : (configuration.isPressed ? K.Hover.pressed : (hover ? K.Hover.fill(on: ground) : K.card.opacity(K.Opacity.chip)))
        configuration.label
            .lineLimit(1)
            .textStyle(.caption.weight(.medium))  // one weight chosen or not, so chips never shift
            .foregroundStyle(selected || hover ? K.text : K.text2)
            .padding(.horizontal, K.Space.s12)
            .frame(height: K.Height.control28)
            .background(fill, in: Capsule())
            // selected-marker: a 1-pt accent ring, 4.8:1 or more (at 60% it was 2.7:1).
            .overlay(Capsule().strokeBorder(selected ? K.selectedMarker : K.border))
            .contentShape(Capsule())
            .focusRingCapsule()
            .onHover { hover = $0 }
            .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// All · production · staging: one chip row that filters a list. nil is "All".
struct ChipRow: View {
    let chips: [String]
    @Binding var selection: String?
    var allTitle = "All"
    var prefix = ""

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: K.Space.s8) {
                Button(allTitle) { selection = nil }.buttonStyle(ChipStyle(selected: selection == nil))
                ForEach(chips, id: \.self) { c in
                    Button(prefix + c) { selection = selection == c ? nil : c }.buttonStyle(ChipStyle(selected: selection == c))
                }
            }
        }
        .scrollIndicators(.never)
        .frame(height: K.Height.control28)
    }
}

/// A compact filter for a long list (the one search stays ⌘K). 28 high.
struct FilterField: View {
    /// The magnifier every card draws in a filter field (PageDatabase, PageMongoQuery, PageHostServices).
    static let symbol = "magnifyingglass"
    let placeholder: String
    @Binding var text: String
    @FocusState private var focused: Bool
    var body: some View {
        FieldBox(focused: focused, compact: true) {
            HStack(spacing: K.Space.s8) {
                Image(systemName: Self.symbol).icon(K.Icon.i12).foregroundStyle(K.text3)
                    .accessibilityHidden(true)
                TextField(placeholder, text: $text).textStyle(.body).focused($focused)
                if !text.isEmpty {
                    Button { text = "" } label: { Image(systemName: "xmark.circle.fill").icon(K.Icon.i12) }
                        .buttonStyle(.plainFocus(K.Radius.r4)).foregroundStyle(K.text3)
                        .help("Clear the filter")
                        .accessibilityLabel("Clear the filter")
                }
            }
        }
    }
}

/// What VoiceOver reads for a ⋯ button: "More for web-1", so twenty buttons in a list are not all "More".
enum MoreMenuWords {
    static func label(_ subject: String?) -> String {
        guard let subject, !subject.isEmpty else { return "More" }
        return "More for \(subject)"
    }
}

/// The ⋯ button that opens a menu: 28 square, or 24 inside a row. It hovers like a ghost square: the ground's
/// hover fill and `text` (design system: k-more). `label` names the row it belongs to, for VoiceOver
/// ("web-1" reads "More for web-1"); `help` is the tooltip, which may list the menu's items.
struct MoreMenu<Items: View>: View {
    var size: CGFloat = K.Height.control28
    /// The thing the menu is for: a target's, key's or forward's name.
    var label: String?
    var help = "More"
    @ViewBuilder var items: () -> Items
    @State private var hover = false
    @Environment(\.hoverGround) private var ground
    var body: some View {
        Menu { items() } label: { Image(systemName: "ellipsis").icon(K.Icon.i16) }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .tint(hover ? K.text : K.text2)
            .foregroundStyle(hover ? K.text : K.text2)
            .frame(width: size, height: size)
            .background(hover ? K.Hover.fill(on: ground) : .clear,
                        in: RoundedRectangle(cornerRadius: K.Radius.r6, style: .continuous))
            .contentShape(Rectangle())
            .onHover { hover = $0 }
            .help(help)
            .accessibilityLabel(MoreMenuWords.label(label))
    }
}
