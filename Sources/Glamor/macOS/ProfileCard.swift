#if os(macOS)
import SwiftUI

/// The person at the bottom of the sidebar: an initial in a circle on the `avatar` fill, the name, a line under it
/// (where the data lives, or the plan once signed in) and a chevron. Pressing it opens the profile menu in a popover,
/// 260 wide, with the caller's content (Appearance, Upgrade, Settings, Account, Team); Escape closes it and the system
/// returns focus to the card. In the rail (`.avatar`) only the circle shows.
///
/// VoiceOver reads one button, "name, detail": the label (initial, lines, chevron) is hidden. Glamor knows no person: the name,
/// the detail line and the menu are the app's.
public struct ProfileCard<Menu: View>: View {
    public let name: String
    public let detail: String
    public let style: ProfileCardStyle
    private let menu: Menu
    @State private var isOpen = false

    public init(name: String, detail: String, style: ProfileCardStyle = .row, @ViewBuilder menu: () -> Menu) {
        self.name = name
        self.detail = detail
        self.style = style
        self.menu = menu()
    }

    /// What VoiceOver reads, and the words of the tooltip: the name, then the detail line when there is one. The tooltip is on the
    /// label, hidden from VoiceOver: on macOS a button's own tooltip is its AXHelp, which would read the name a second time.
    var spokenName: String { detail.isEmpty ? name : "\(name), \(detail)" }

    /// The first letter of the name, in capitals; nil when the name has none.
    var initial: String? {
        name.trimmingCharacters(in: .whitespacesAndNewlines).first.map { String($0).uppercased() }
    }

    public var body: some View {
        Button { isOpen.toggle() } label: {
            Group {
                switch style {
                case .row: row
                case .avatar: avatar
                }
            }
            .help(spokenName)
            .accessibilityHidden(true)
        }
        .buttonStyle(ProfileCardButtonStyle(style: style))
        .accessibilityLabel(spokenName)
        .popover(isPresented: $isOpen, arrowEdge: style == .row ? .top : .trailing) {
            menu.frame(width: G.Width.profileMenu)
        }
    }

    /// The tile, the two lines and the chevron, 12 apart as a tile and its text are in every row (`space-3`). That is not the
    /// 8 between a label and its icon: the chevron sits at the far end behind a spacer, so it is not paired with the words.
    private var row: some View {
        HStack(spacing: G.Space.s12) {
            avatar
            lines
            Spacer(minLength: G.Space.s8)
            chevron
        }
    }

    private var lines: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(name).textStyle(.bodyMedium).foregroundStyle(G.text).lineLimit(1)
            Text(detail).textStyle(.caption).foregroundStyle(G.text2).lineLimit(1)
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.up.chevron.down").icon(G.Icon.sm).foregroundStyle(G.text3)
    }

    /// One solid circle, the same in both themes. A name with no letter shows the person glyph instead of an initial.
    private var avatar: some View {
        Circle().fill(G.avatar)
            .frame(width: G.Tile.t32, height: G.Tile.t32)
            .overlay {
                if let initial {
                    Text(initial).textStyle(.bodyMedium).foregroundStyle(G.onAvatar)
                } else {
                    Image(systemName: "person.fill").icon(G.Icon.md).foregroundStyle(G.onAvatar)
                }
            }
    }
}
#endif
