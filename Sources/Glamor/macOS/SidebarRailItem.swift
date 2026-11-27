#if os(macOS)
import SwiftUI

/// One area in the rail: a glyph over its short title, in a button 52 high (a pointer target of 44 or more). The chosen
/// area is the item look of variant A (`panel` fill, hairline and the marker). VoiceOver reads the short title once, and
/// the selected trait; the tooltip is the full title, since the 64 wide label clips a long name.
struct SidebarRailItem: View {
    let area: SidebarRailArea
    let isSelected: Bool
    let action: () -> Void

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
        }
        .buttonStyle(SidebarItemStyle(isSelected: isSelected, height: G.Height.row52, alignment: .center, horizontalPadding: 0))
        .help(area.help)
        .accessibilityLabel(area.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
#endif
