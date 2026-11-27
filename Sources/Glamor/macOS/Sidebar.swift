#if os(macOS)
import SwiftUI

/// The Mac sidebar (variant A): the window's ground, a top row with the traffic lights' room and the Hide button, the
/// caller's header (logo, name, `SidebarSearch`), a scrolling content area, and a footer pinned under a hairline.
/// The edge is the one `SplitDivider`: 200 to 320, hides when dragged under the smallest. The app saves the width
/// (`SizeStore`), owns the Hide command (⌃⌘S) and supplies every word that is its own (place titles, counts).
///
/// Its content is a plain stack: a lazy one leaves the rows below the fold out of the accessibility tree and out
/// of the Tab order until they are scrolled to, and a sidebar has about 25 rows.
/// Variant B (the narrow window) passes `isResizable: false` and a fixed width for its column.
public struct Sidebar<Header: View, Content: View, Footer: View>: View {
    @Binding public var width: CGFloat
    public let isResizable: Bool
    public let onHide: () -> Void
    private let header: Header
    private let content: Content
    private let footer: Footer

    public init(width: Binding<CGFloat>, isResizable: Bool = true, onHide: @escaping () -> Void,
                @ViewBuilder header: () -> Header, @ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer) {
        _width = width
        self.isResizable = isResizable
        self.onHide = onHide
        self.header = header()
        self.content = content()
        self.footer = footer()
    }

    public var body: some View {
        VStack(spacing: 0) {
            topRow
            header.padding(.horizontal, G.Row.listInset).padding(.bottom, G.Space.s8)
            ScrollView {
                VStack(alignment: .leading, spacing: G.Row.gap) { content }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(G.Row.listInset)
            }
            Hairline()
            footer.padding(G.Row.listInset)
        }
        .frame(width: width)
        .frame(maxHeight: .infinity)
        .background(G.window)
        .hoverGround(.window)
        .overlay(alignment: .trailing) {
            if isResizable {
                SplitDivider(axis: .horizontal, value: $width, area: G.Resize.sidebar,
                             label: GlamorText.string(.sidebarWidth), sizes: .leading, hairline: false, onCollapse: onHide)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(GlamorText.string(.sidebarLabel))
    }

    /// Where the traffic lights sit: the window drags from here, and the Hide button is at the far end.
    private var topRow: some View {
        let hide = GlamorText.string(.sidebarHide)
        return HStack(spacing: 0) {
            Spacer(minLength: 0)
            Button(action: onHide) { Image(systemName: "sidebar.left").icon(G.Icon.md) }
                .buttonStyle(GhostButtonStyle(square: true, size: G.Height.control24))
                .help(hide)
                .accessibilityLabel(hide)
        }
        .padding(.horizontal, G.Row.listInset)
        .frame(height: G.Height.trafficLights)
        .background(WindowDragArea())
    }
}
#endif
