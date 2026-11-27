#if os(macOS)
import SwiftUI

/// The header and the rows of a `SidebarSection`, for a binding to the open state.
/// The header is the 32 high row of an item (`SidebarItemStyle`), so its title starts where the row names start and
/// it has the same hover and focus ring. VoiceOver reads the title as the caller wrote it, a header trait, and
/// "expanded" or "collapsed" as its value. A folded section draws no rows, so the marker and the panel fill of the
/// chosen place go with them: when it holds that place, the header shows a marker-coloured dot and its value names
/// the place ("collapsed, Host selected"). The hint says what pressing it does.
struct SidebarSectionBody<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    let containsSelection: Bool
    let selectedTitle: String?
    private let content: Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(title: String, isExpanded: Binding<Bool>, containsSelection: Bool = false, selectedTitle: String? = nil,
         @ViewBuilder content: () -> Content) {
        self.title = title
        _isExpanded = isExpanded
        self.containsSelection = containsSelection
        self.selectedTitle = selectedTitle
        self.content = content()
    }

    /// What VoiceOver reads after the title. An open section says "expanded" alone: its chosen row is drawn and read there.
    static func headerValue(isExpanded: Bool, selectedTitle: String?, language: String? = nil) -> String {
        if isExpanded { return GlamorText.string(.sidebarExpanded, language: language) }
        guard let selectedTitle else { return GlamorText.string(.sidebarCollapsed, language: language) }
        return GlamorText.string(.sidebarCollapsedSelected, language: language, selectedTitle)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: G.Row.gap) {
            Button { withGAnimation(.fast) { isExpanded.toggle() } } label: {
                HStack(spacing: G.Space.labelIcon) {
                    Text(title.uppercased()).textStyle(.sectionLabel).tracking(G.Font.sectionTracking).lineLimit(1)
                    Spacer(minLength: G.Space.s8)
                    if !isExpanded && containsSelection {
                        Circle().fill(G.selectedMarker).frame(width: G.Dot.d8, height: G.Dot.d8)
                            .accessibilityHidden(true)
                    }
                    Image(systemName: "chevron.right").icon(G.Icon.xs, weight: .semibold)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        // Reduce Motion: the chevron jumps. The rows still fade (gTransition).
                        .transaction { if reduceMotion { $0.animation = nil } }
                }
                .foregroundStyle(G.text3)
            }
            .buttonStyle(SidebarItemStyle(isSelected: false))
            .accessibilityLabel(title)
            .accessibilityValue(Self.headerValue(isExpanded: isExpanded, selectedTitle: selectedTitle))
            .accessibilityHint(GlamorText.string(.sidebarSectionHint))
            .accessibilityAddTraits(.isHeader)
            if isExpanded {
                VStack(alignment: .leading, spacing: G.Row.gap) { content }.gTransition(.fade)
            }
        }
    }
}
#endif
