#if os(macOS)
import AppKit
import Glamor
import SwiftUI

/// The narrow-window sidebar (variant B): the rail of areas with the avatar in its footer, and the column of the chosen
/// section beside it. Home and Settings show no column. Its controls and their Tab order (rail, then column) are the
/// `sidebar-b` list in scripts/window/WindowCheck.swift.
struct SidebarBScene: View {
    @State private var area = SidebarBScene.startArea
    @State private var selection = SidebarDemo.start

    /// The area that is chosen when the scene opens: a section, so the column shows.
    static let startArea = "targets"

    var body: some View {
        let registry = SidebarDemo.registry
        HStack(spacing: 0) {
            SidebarRail(registry: registry, area: $area) { ProfileDemo.card(.avatar) }
            if let section = registry.sections.first(where: { $0.id == area }) {
                SidebarColumn(section.title) {
                    SidebarSearch(action: { activated("search") })
                    ForEach(section.places) { SidebarItem(place: $0, selection: $selection, count: SidebarDemo.counts[$0.id]) }
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(G.window)
        .onChange(of: area) { activated("area \(area)") }
        .onChange(of: selection) { activated(selection) }
        .background(EnvironmentProbe())
    }
}

extension GalleryScenes {
    /// 256 by 680, as `sidebar-a`: the rail's 72 and the column's 184 fill the default sidebar width.
    static let sidebarB = GalleryScene(name: "sidebar-b", size: CGSize(width: G.Width.sidebar, height: G.Height.windowMin)) {
        NSHostingView(rootView: SidebarBScene())
    }
}
#endif
