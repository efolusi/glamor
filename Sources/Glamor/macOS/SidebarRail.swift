#if os(macOS)
import SwiftUI

/// The narrow-window sidebar (variant B), first half: a rail 72 wide with one button per area (Home, each section of the
/// registry, Settings) and the caller's footer pinned at the bottom (the profile avatar). The chosen area is `area`, the
/// id of Home, a section or Settings; pressing an item sets it. Home and Settings have no column: the app draws a
/// `SidebarColumn` beside the rail only for a section, with that section's places.
///
/// The rail keeps no state of its own. Like `Sidebar` it sits on the window's ground, leaves the traffic lights their
/// room and drags the window from there, and holds its items in a plain stack so every area stays in the Tab order.
public struct SidebarRail<Footer: View>: View {
    let registry: PlaceRegistry
    @Binding var area: String
    private let footer: Footer

    public init(registry: PlaceRegistry, area: Binding<String>, @ViewBuilder footer: () -> Footer) {
        self.registry = registry
        _area = area
        self.footer = footer()
    }

    public var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: G.Height.trafficLights).background(WindowDragArea())
            VStack(spacing: G.Row.gap) {
                ForEach(SidebarRailArea.all(in: registry)) { item in
                    SidebarRailItem(area: item, isSelected: area == item.id) { area = item.id }
                }
            }
            .padding(.horizontal, G.Row.cardInset)
            Spacer(minLength: G.Space.s8)
            footer.padding(.bottom, G.Row.listInset)
        }
        .frame(width: G.Width.rail)
        .frame(maxHeight: .infinity)
        .background(G.window)
        .hoverGround(.window)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(GlamorText.string(.sidebarLabel))
    }
}
#endif
