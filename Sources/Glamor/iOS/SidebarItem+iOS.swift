#if os(iOS)
import SwiftUI

/// One place in a sidebar list on iPad and iPhone: a symbol, its name and, when the caller gives one, a count. The
/// same two inits and the same VoiceOver words as the Mac's `SidebarItem`. The system's `.sidebarAdaptable` draws
/// its own rows; this one is for the list inside an area (iPhone) and the column of a split view (iPad).
public struct SidebarItem: View {
    let title: String
    let symbol: String
    let isSelected: Bool
    let count: SidebarCount?
    let help: String?
    let action: () -> Void
    /// 20 at the default text size, growing with Dynamic Type.
    @ScaledMetric(relativeTo: .title3) private var symbolWidth: CGFloat = G.Icon.lg

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

    /// The caller's extra words, as the row's tooltip (and so its accessibility hint); nil when there are none.
    var rowHelp: String? { help }

    /// The name as a pointer tooltip on the text, only when the caller gave no `help`. The text is hidden from
    /// VoiceOver, which reads the row's own label.
    var nameTooltip: String? { help == nil ? title : nil }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: G.Space.labelIcon) {
                Image(systemName: symbol).font(G.icon).frame(width: symbolWidth).accessibilityHidden(true)
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
        Text(title).font(G.body)
            .help(ifPresent: nameTooltip)
            .accessibilityHidden(true)
    }

    /// `accentFg` on `accentSubtle`, never `accent` as text (copper is 2.72:1 on a card). Spoken through the row's
    /// value, so hidden here.
    private func countPill(_ count: SidebarCount) -> some View {
        Text(count.value, format: .number)
            .font(G.small).monospacedDigit()
            .fixedSize()
            .foregroundStyle(G.accentFg)
            .padding(.horizontal, G.Space.s8).padding(.vertical, G.Space.s4)
            .background(G.accentSubtle, in: Capsule())
            .accessibilityHidden(true)
    }
}

private extension View {
    /// `help(_:)` only when there is a text: an empty or absent tooltip must not become the control's hint.
    @ViewBuilder func help(ifPresent text: String?) -> some View {
        if let text { help(text) } else { self }
    }
}
#endif
