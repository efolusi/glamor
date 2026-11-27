#if os(macOS)
import SwiftUI

/// The header and the rows of a `SidebarSection`, for a binding to the open state.
/// The header is the 32 high row of an item (`SidebarItemStyle`), so its title starts where the row names start and
/// it has the same hover and focus ring. VoiceOver reads the title as the caller wrote it, a header trait, and
/// "expanded" or "collapsed" as its value.
struct SidebarSectionBody<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    private let content: Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(title: String, isExpanded: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title
        _isExpanded = isExpanded
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: G.Row.gap) {
            Button { withGAnimation(.fast) { isExpanded.toggle() } } label: {
                HStack(spacing: G.Space.labelIcon) {
                    Text(title.uppercased()).textStyle(.sectionLabel).tracking(G.Font.sectionTracking).lineLimit(1)
                    Spacer(minLength: G.Space.s8)
                    Image(systemName: "chevron.right").icon(G.Icon.xs, weight: .semibold)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        // Reduce Motion: the chevron jumps. The rows still fade (gTransition).
                        .transaction { if reduceMotion { $0.animation = nil } }
                }
                .foregroundStyle(G.text3)
            }
            .buttonStyle(SidebarItemStyle(isSelected: false))
            .accessibilityLabel(title)
            .accessibilityValue(isExpanded ? GlamorText.string(.sidebarExpanded) : GlamorText.string(.sidebarCollapsed))
            .accessibilityAddTraits(.isHeader)
            if isExpanded {
                VStack(alignment: .leading, spacing: G.Row.gap) { content }.gTransition(.fade)
            }
        }
    }
}
#endif
