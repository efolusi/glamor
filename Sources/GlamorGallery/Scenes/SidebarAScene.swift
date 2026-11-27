#if os(macOS)
import AppKit
import Glamor
import SwiftUI

/// The Mac sidebar (variant A): Home, four folding sections of places, Settings pinned in the footer. Its controls and
/// their Tab order are the `sidebar-a` list in scripts/window/WindowCheck.swift. The sections keep their open state
/// in plain `@State`: the gallery hosts this view in a bare `NSHostingView`, where `SceneStorage` has no scene.
struct SidebarAScene: View {
    @State private var selection = SidebarDemo.start
    @State private var width = G.Width.sidebar
    /// A section id mapped to false once it is folded; an id that is absent is open (all four open at the start).
    @State private var folded: [String: Bool] = [:]

    /// What the window check reads in the window title after a section folds or opens: names, not words.
    private static let opened = "opened"
    private static let closed = "closed"

    var body: some View {
        let registry = SidebarDemo.registry
        Sidebar(width: $width, onHide: { activated("hide") }) {
            VStack(alignment: .leading, spacing: G.Space.s12) {
                // The product name is data, not a word to translate; the logo is a placeholder, not a mark.
                Text(verbatim: "komando").textStyle(.titleS).foregroundStyle(G.text).padding(.horizontal, G.Row.padding)
                SidebarSearch(action: { activated("search") })
            }
        } content: {
            item(registry.home)
            ForEach(registry.sections) { section in
                SidebarSection(section.title, isExpanded: expanded(section.id)) {
                    ForEach(section.places) { item($0) }
                }
            }
        } footer: {
            item(registry.settings)
        }
        .onChange(of: selection) { activated(selection) }
        .background(EnvironmentProbe())
    }

    private func item(_ place: Place) -> some View {
        SidebarItem(place: place, selection: $selection, count: SidebarDemo.counts[place.id])
    }

    /// The open state of one section; folding or opening it is recorded as an activation for the window check.
    private func expanded(_ id: String) -> Binding<Bool> {
        Binding(get: { folded[id] != true },
                set: { open in
                    folded[id] = open ? nil : true
                    activated("\(id) \(open ? Self.opened : Self.closed)")
                })
    }
}

extension GalleryScenes {
    /// 256 by 680 (`G.Height.windowMin`): the sidebar's default width in the main window's smallest height, so the
    /// scrolling case is the first thing a person and the window check see.
    static let sidebarA = GalleryScene(name: "sidebar-a", size: CGSize(width: G.Width.sidebar, height: G.Height.windowMin)) {
        NSHostingView(rootView: SidebarAScene())
    }
}
#endif
