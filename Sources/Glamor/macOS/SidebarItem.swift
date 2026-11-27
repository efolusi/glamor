#if os(macOS)
import SwiftUI

/// One place in the sidebar: a symbol, its name and, when the caller gives one, a count. The chosen row is drawn by
/// `SidebarItemStyle`. VoiceOver reads one name (the title), the count's spoken words as its value and the
/// selected trait; the symbol and the count's pill are not read a second time. A `help` is the row's tooltip. Without
/// one the name is the tooltip of the (clipped) text alone: on macOS a tooltip is the row's AXHelp, so the name as the
/// row's tooltip would be read a second time.
public struct SidebarItem: View {
    let title: String
    let symbol: String
    let isSelected: Bool
    let count: SidebarCount?
    let help: String?
    let action: () -> Void

    public init(_ title: String, symbol: String, isSelected: Bool,
                count: SidebarCount? = nil, help: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.symbol = symbol
        self.isSelected = isSelected
        self.count = count
        self.help = help
        self.action = action
    }

    /// A row for a place of the registry: selected while `selection` holds its id, and pressing it selects it.
    public init(place: Place, selection: Binding<Place.ID>, count: SidebarCount? = nil) {
        self.init(place.title, symbol: place.symbol, isSelected: selection.wrappedValue == place.id, count: count) {
            selection.wrappedValue = place.id
        }
    }

    /// What VoiceOver reads after the name: the count's words, or nothing.
    var spokenValue: String { count?.spoken ?? "" }

    /// The caller's extra words, as the row's tooltip (and so its help text for VoiceOver); nil when there are none.
    var rowHelp: String? { help }

    /// The name as a hover tooltip on the text, only when the caller gave no `help` (a narrow sidebar clips long names).
    /// The text is hidden from VoiceOver, which reads the row's own label.
    var nameTooltip: String? { help == nil ? title : nil }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: G.Space.labelIcon) {
                Image(systemName: symbol).icon(G.Icon.md)
                nameText
                Spacer(minLength: G.Space.s8)
                if let count { countPill(count) }
            }
            .foregroundStyle(isSelected ? G.text : G.text2)
        }
        .buttonStyle(SidebarItemStyle(isSelected: isSelected))
        .help(ifPresent: rowHelp)
        .accessibilityLabel(title)
        .accessibilityValue(spokenValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var nameText: some View {
        Text(title).textStyle(.body).lineLimit(1)
            .help(ifPresent: nameTooltip)
            .accessibilityHidden(true)
    }

    /// `accentFg` on `accentSubtle`, never `accent` as text (copper is 2.72:1 on a card); tabular so a count that
    /// changes does not move the name. Spoken through the row's value, so hidden here.
    private func countPill(_ count: SidebarCount) -> some View {
        Text(count.value, format: .number)
            .textStyle(.small).monospacedDigit()
            .foregroundStyle(G.accentFg)
            .padding(.horizontal, G.Space.s8)
            .frame(height: G.Height.pill)
            .background(G.accentSubtle, in: Capsule())
            .accessibilityHidden(true)
    }
}

private extension View {
    /// `help(_:)` only when there is a text: an empty or absent tooltip must not become the control's help text.
    @ViewBuilder func help(ifPresent text: String?) -> some View {
        if let text { help(text) } else { self }
    }
}
#endif
