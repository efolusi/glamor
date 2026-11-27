#if os(macOS)
import SwiftUI

/// One area in the rail: a glyph over its short title, in a button 52 high (a pointer target of 44 or more). The chosen
/// area is the item look of variant A (`panel` fill, hairline and the marker). VoiceOver reads the short title once, and
/// the selected trait. The tooltip is the full title, only where it adds words to the short one, and sits on the label
/// (hidden from VoiceOver), not on the button: on macOS a button's tooltip is its AXHelp, read after its name.
struct SidebarRailItem: View {
    let area: SidebarRailArea
    let isSelected: Bool
    let action: () -> Void

    /// The glyph over the title is 20 + 4 + 16 = 40 tall, centred in the 52: it starts 6 from the top.
    static let contentHeight = G.Icon.lg + G.Space.s4 + G.Height.line16
    static let contentTop = (G.Height.row52 - contentHeight) / 2
    /// The chosen marker is as tall as the glyph and starts where it starts, so it ends 4 above the title: a long title (the
    /// Indonesian "Pengaturan" starts at x 4.5 at its floor) never runs under the marker at x 4 to 8.
    static let markerHeight = G.Icon.lg

    /// What the short title has to sit in: the rail less the inset of the list on each side. The item pads its
    /// content by nothing, so the title gets the button's whole width.
    static let labelRoom = G.Width.rail - 2 * G.Row.cardInset

    var body: some View {
        Button(action: action) {
            VStack(spacing: G.Space.s4) {
                Image(systemName: area.symbol).icon(G.Icon.lg)
                Text(area.name).textStyle(.caption).lineLimit(1).minimumScaleFactor(G.Row.railTitleScale)
            }
            .foregroundStyle(isSelected ? G.text : G.text2)
            .help(ifPresent: area.tooltip)
            .accessibilityHidden(true)
        }
        .buttonStyle(SidebarItemStyle(isSelected: isSelected, height: G.Height.row52, alignment: .center, horizontalPadding: 0,
                                     markerHeight: Self.markerHeight, markerTop: Self.contentTop))
        .accessibilityLabel(area.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
#endif
