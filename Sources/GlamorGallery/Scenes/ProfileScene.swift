#if os(macOS)
import AppKit
import Glamor
import SwiftUI

/// The profile card as the sidebar's footer shows it: the two-line row at the bottom of a sidebar-wide window, with its
/// menu in a popover. Its one control is the `profile` list in scripts/window/WindowCheck.swift.
struct ProfileScene: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            Hairline()
            ProfileDemo.card(.row).padding(G.Row.listInset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(G.window)
        .hoverGround(.window)
        .background(EnvironmentProbe())
    }
}

extension GalleryScenes {
    /// The sidebar's width, and the height of one card with its padding and a line above.
    static let profile = GalleryScene(name: "profile", size: CGSize(width: G.Width.sidebar, height: G.Height.row64 + G.Height.row32)) {
        NSHostingView(rootView: ProfileScene())
    }
}
#endif
