#if os(macOS)
import SwiftUI

/// One place in the sidebar: a symbol, its name and, when the caller gives one, a count. The chosen row is drawn by
/// `SidebarItemStyle`. VoiceOver reads one name (the title), the count's spoken words as its value and the
/// selected trait; the symbol and the count's pill are not read a second time. The tooltip is `help`, else the title.
public struct SidebarItem: View {
    public let title: String
    public let symbol: String
    public let isSelected: Bool
    public let count: SidebarCount?
    public let help: String?
    public let action: () -> Void

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

    /// The hover help: the caller's, or else the row's own name (a narrow sidebar clips long names).
    var tooltip: String { help ?? title }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: G.Space.labelIcon) {
                Image(systemName: symbol).icon(G.Icon.md)
                Text(title).textStyle(.body).lineLimit(1)
                Spacer(minLength: G.Space.s8)
                if let count { countPill(count) }
            }
            .foregroundStyle(isSelected ? G.text : G.text2)
        }
        .buttonStyle(SidebarItemStyle(isSelected: isSelected))
        .help(tooltip)
        .accessibilityLabel(title)
        .accessibilityValue(spokenValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
#endif
