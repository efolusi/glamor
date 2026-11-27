#if os(macOS)
import SwiftUI

/// The narrow-window sidebar (variant B), second half: the places of the chosen area, in the 184 that the 72 wide
/// `SidebarRail` leaves of the 256 sidebar. Its title (`titleS`, 16 semibold) sits in the row of the traffic lights; the
/// rows are the caller's `SidebarItem`s and a `SidebarSearch`, in a plain scrolling stack. It is named by its title.
public struct SidebarColumn<Content: View>: View {
    public let title: String
    private let content: Content

    /// What is left of the sidebar's width after the rail.
    static var width: CGFloat { G.Width.sidebar - G.Width.rail }

    public init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            Text(title).textStyle(.titleS).foregroundStyle(G.text).lineLimit(1)
                .padding(.horizontal, G.Row.padding)
                .frame(maxWidth: .infinity, minHeight: G.Height.trafficLights, maxHeight: G.Height.trafficLights, alignment: .leading)
                .background(WindowDragArea())
                .accessibilityAddTraits(.isHeader)
            ScrollView {
                VStack(alignment: .leading, spacing: G.Row.gap) { content }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(G.Row.listInset)
            }
        }
        .frame(width: Self.width)
        .frame(maxHeight: .infinity)
        .background(G.window)
        .hoverGround(.window)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }
}
#endif
