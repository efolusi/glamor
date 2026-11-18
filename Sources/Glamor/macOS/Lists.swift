#if os(macOS)
import SwiftUI

// Lists before cards (Layout rules): inventories are one-line rows in a card, filtered by chips.

/// Rows in one card, with hairlines between them.
public struct CardList<Content: View>: View {
    public var inset: CGFloat = G.Space.s16
    @ViewBuilder public var content: () -> Content
    public var body: some View {
        VStack(spacing: 0) {
            Group(subviews: content()) { subviews in
                ForEach(Array(subviews.enumerated()), id: \.offset) { i, v in
                    v
                    if i < subviews.count - 1 { Hairline(color: G.border.opacity(G.Opacity.softHairline)).padding(.leading, inset) }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: G.radius, style: .continuous))
        .card()
    }

    public init(inset: CGFloat = G.Space.s16, @ViewBuilder content: @escaping () -> Content) {
        self.inset = inset
        self.content = content
    }
}

/// A label on the left, its value on the right: 40 high.
public struct InfoRow<Value: View>: View {
    public let label: String
    @ViewBuilder public var value: () -> Value
    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(label).foregroundStyle(G.text2)
            Spacer(minLength: G.Space.s20)
            value().foregroundStyle(G.text).multilineTextAlignment(.trailing).textSelection(.enabled)
        }
        .textStyle(.body)
        .padding(.horizontal, G.Space.s16)
        .padding(.vertical, G.Space.s4)       // only matters when a value wraps
        .frame(minHeight: G.Height.row40)
    }

    public init(label: String, @ViewBuilder value: @escaping () -> Value) {
        self.label = label
        self.value = value
    }
}

public extension InfoRow where Value == Text {
    init(_ label: String, _ value: String) { self.init(label: label) { Text(value) } }
}

// MARK: Selectable rows (design system: ListRow)
//
// One spec for every list a person picks from (G.Row): the highlight sits 8 in from a side list's
// edge (4 in a card), 2 apart from the next row, with 8 corners; the text starts 12 inside it, so it
// stays at the same place at rest, under the pointer, selected and focused. Under the pointer the row takes
// the hover fill of its ground (G.Hover: onCard in a card, onPanel in a side list); pressed, G.Hover.pressed;
// selected, `accent` at 10% with the selected-marker; focused, the 2-pt `focus` ring on the highlight's own shape.

/// The highlight behind a selectable row. Use `.buttonStyle(.row(...))` for a row that is a Button; use
/// this for a row that handles its own clicks (a double click, a drag).
public struct RowHighlight: ViewModifier {
    public var selected: Bool = false
    public var hover: Bool = false
    public var pressed: Bool = false
    /// Debug galleries only: draw the focus ring without keyboard focus.
    public var showFocus: Bool = false
    @Environment(\.isFocused) private var isFocused
    @Environment(\.hoverGround) private var ground

    public func body(content: Content) -> some View {
        let focused = isFocused || showFocus
        let shape = RoundedRectangle(cornerRadius: G.Row.radius, style: .continuous)
        content
            .background(selected ? G.accent.opacity(G.Opacity.selected)
                        : G.Hover.item(hover: hover, pressed: pressed, on: ground), in: shape)
            .overlay { if focused { shape.strokeBorder(G.focus, lineWidth: G.Line.strong).allowsHitTesting(false) } }
            .selectedMarker(selected)
            .focusEffectDisabled()
    }

    public init(selected: Bool = false, hover: Bool = false, pressed: Bool = false, showFocus: Bool = false) {
        self.selected = selected
        self.hover = hover
        self.pressed = pressed
        self.showFocus = showFocus
    }
}

public extension View {
    /// The ListRow highlight: the ground's hover fill under the pointer, `accent` at 10% and the marker when selected.
    func rowHighlight(selected: Bool = false, hover: Bool = false) -> some View {
        modifier(RowHighlight(selected: selected, hover: hover))
    }

    /// A ListRow's look for a debug gallery: padding, height and highlight, with the focus ring forced.
    func rowLook(selected: Bool = false, hover: Bool = false, focus: Bool = false, height: CGFloat = G.Row.oneLine) -> some View {
        padding(.horizontal, G.Row.padding)
            .frame(maxWidth: .infinity, minHeight: height, alignment: .leading)
            .modifier(RowHighlight(selected: selected, hover: hover, showFocus: focus))
    }
}

/// A row a person clicks to pick or open something: G.Row.padding inside, at least `height` high
/// (32 for one line, 52 for a name over a line of help), with the ListRow highlight. The label lays out
/// its own content; the style adds the padding, the highlight, the focus ring and the selected trait.
public struct RowStyle: ButtonStyle {
    public var selected: Bool = false
    public var height: CGFloat = G.Row.oneLine
    @State private var hover = false

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, G.Row.padding)
            .frame(maxWidth: .infinity, minHeight: height, alignment: .leading)
            .contentShape(Rectangle())
            .modifier(RowHighlight(selected: selected, hover: hover, pressed: configuration.isPressed))
            .onHover { hover = $0 }
            .accessibilityAddTraits(selected ? .isSelected : [])
    }

    public init(selected: Bool = false, height: CGFloat = G.Row.oneLine) {
        self.selected = selected
        self.height = height
    }
}

public extension ButtonStyle where Self == RowStyle {
    /// A ListRow: `.buttonStyle(.row(selected: picked == item))`, `height: G.Row.twoLine` for two lines.
    static func row(selected: Bool = false, height: CGFloat = G.Row.oneLine) -> RowStyle {
        RowStyle(selected: selected, height: height)
    }
}

/// A side list's rows (Recipes, the schema, collections, cache keys): G.Row.listInset from every edge
/// and G.Row.gap between rows. Put it inside the ScrollView.
public struct SideListStack<Content: View>: View {
    @ViewBuilder public var content: () -> Content
    public var body: some View {
        LazyVStack(alignment: .leading, spacing: G.Row.gap) { content() }
            .padding(G.Row.listInset)
    }

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
}

/// A group's name in a side list, in line with the rows' text (listInset + padding = 20 from the edge).
public struct ListSectionLabel: View {
    public let title: String
    public init(_ title: String) { self.title = title }
    public var body: some View {
        Text(title.uppercased()).textStyle(.sectionLabel).tracking(G.Font.sectionTracking).foregroundStyle(G.text3)
            .frame(height: G.Height.line16)
            .padding(.horizontal, G.Row.padding).padding(.top, G.Space.s12).padding(.bottom, G.Space.s4)
            .accessibilityAddTraits(.isHeader)
    }
}

/// "PRODUCTION": a group's name above a card of rows, inset 16 so it lines up with the names in the card.
public struct CardSectionLabel: View {
    public let title: String
    public init(_ title: String) { self.title = title }
    public var body: some View {
        Text(title.uppercased()).textStyle(.sectionLabel).tracking(G.Font.sectionTracking).foregroundStyle(G.text3)
            .padding(.horizontal, G.Space.s16)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A clickable row in a CardList: the highlight G.Row.cardInset in from the card on every side, the
/// text 16 from the card's edge (where the hairlines start). 40 high unless the content is taller.
public struct ListRow<Content: View>: View {
    public var height: CGFloat = G.Height.row40
    public var selected: Bool = false
    public let action: () -> Void
    @ViewBuilder public var content: () -> Content

    public var body: some View {
        Button(action: action) {
            HStack(spacing: G.Space.s12) { content() }
        }
        .buttonStyle(.row(selected: selected, height: height - 2 * G.Row.cardInset))
        .padding(G.Row.cardInset)
    }

    public init(height: CGFloat = G.Height.row40, selected: Bool = false, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.height = height
        self.selected = selected
        self.action = action
        self.content = content
    }
}

/// A rounded word that is either chosen or not, like a filter chip (design system: Chip). Only the chosen
/// one has the ring, so a chip under the pointer never looks chosen.
public struct ChipStyle: ButtonStyle {
    public let selected: Bool
    @State private var hover = false
    @Environment(\.hoverGround) private var ground
    public func makeBody(configuration: Configuration) -> some View {
        let fill: Color = selected ? G.cardHover
            : (configuration.isPressed ? G.Hover.pressed : (hover ? G.Hover.fill(on: ground) : G.card.opacity(G.Opacity.chip)))
        configuration.label
            .lineLimit(1)
            .textStyle(.caption.weight(.medium))  // one weight chosen or not, so chips never shift
            .foregroundStyle(selected || hover ? G.text : G.text2)
            .padding(.horizontal, G.Space.s12)
            .frame(height: G.Height.control28)
            .background(fill, in: Capsule())
            // selected-marker: a 1-pt accent ring, 4.8:1 or more (at 60% it was 2.7:1).
            .overlay(Capsule().strokeBorder(selected ? G.selectedMarker : G.border))
            .contentShape(Capsule())
            .focusRingCapsule()
            .onHover { hover = $0 }
            .accessibilityAddTraits(selected ? .isSelected : [])
    }

    public init(selected: Bool) {
        self.selected = selected
    }
}

/// All · production · staging: one chip row that filters a list. nil is "All".
public struct ChipRow: View {
    public let chips: [String]
    @Binding public var selection: String?
    public var allTitle: String = "All"
    public var prefix: String = ""

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: G.Space.s8) {
                Button(allTitle) { selection = nil }.buttonStyle(ChipStyle(selected: selection == nil))
                ForEach(chips, id: \.self) { c in
                    Button(prefix + c) { selection = selection == c ? nil : c }.buttonStyle(ChipStyle(selected: selection == c))
                }
            }
        }
        .scrollIndicators(.never)
        .frame(height: G.Height.control28)
    }

    public init(chips: [String], selection: Binding<String?>, allTitle: String = "", prefix: String = "") {
        self.chips = chips
        self._selection = selection
        self.allTitle = allTitle
        self.prefix = prefix
    }
}

/// A compact filter for a long list (the one search stays ⌘K). 28 high.
public struct FilterField: View {
    /// The magnifier every card draws in a filter field (PageDatabase, PageMongoQuery, PageHostServices).
    public static let symbol = "magnifyingglass"
    public let placeholder: String
    @Binding public var text: String
    @FocusState private var focused: Bool
    public var body: some View {
        FieldBox(focused: focused, compact: true) {
            HStack(spacing: G.Space.s8) {
                Image(systemName: Self.symbol).icon(G.Icon.i12).foregroundStyle(G.text3)
                    .accessibilityHidden(true)
                TextField(placeholder, text: $text).textStyle(.body).focused($focused)
                if !text.isEmpty {
                    Button { text = "" } label: { Image(systemName: "xmark.circle.fill").icon(G.Icon.i12) }
                        .buttonStyle(.plainFocus(G.Radius.r4)).foregroundStyle(G.text3)
                        .help("Clear the filter")
                        .accessibilityLabel("Clear the filter")
                }
            }
        }
    }

    public init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
}

/// What VoiceOver reads for a ⋯ button: "More for web-1", so twenty buttons in a list are not all "More".
public enum MoreMenuWords {
    public static func label(_ subject: String?) -> String {
        guard let subject, !subject.isEmpty else { return "More" }
        return "More for \(subject)"
    }
}

/// The ⋯ button that opens a menu: 28 square, or 24 inside a row. It hovers like a ghost square: the ground's
/// hover fill and `text` (design system: k-more). `label` names the row it belongs to, for VoiceOver
/// ("web-1" reads "More for web-1"); `help` is the tooltip, which may list the menu's items.
public struct MoreMenu<Items: View>: View {
    public var size: CGFloat = G.Height.control28
    /// The thing the menu is for: a target's, key's or forward's name.
    public var label: String?
    public var help: String = "More"
    @ViewBuilder public var items: () -> Items
    @State private var hover = false
    @Environment(\.hoverGround) private var ground
    public var body: some View {
        Menu { items() } label: { Image(systemName: "ellipsis").icon(G.Icon.i16) }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .tint(hover ? G.text : G.text2)
            .foregroundStyle(hover ? G.text : G.text2)
            .frame(width: size, height: size)
            .background(hover ? G.Hover.fill(on: ground) : .clear,
                        in: RoundedRectangle(cornerRadius: G.Radius.r6, style: .continuous))
            .contentShape(Rectangle())
            .onHover { hover = $0 }
            .help(help)
            .accessibilityLabel(MoreMenuWords.label(label))
    }

    public init(size: CGFloat = G.Height.control28, label: String?, help: String = "", @ViewBuilder items: @escaping () -> Items) {
        self.size = size
        self.label = label
        self.help = help
        self.items = items
    }
}
#endif
