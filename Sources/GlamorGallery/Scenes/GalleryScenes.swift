#if os(macOS)
import AppKit
import SwiftUI

/// Every scene the gallery can show. A new scene is one file in this folder and one line in `all`.
enum GalleryScenes {
    static let components = GalleryScene(name: "components", size: CGSize(width: 460, height: 560)) {
        NSHostingView(rootView: ComponentsScene())
    }

    static let marks = GalleryScene(name: "marks", size: CGSize(width: 460, height: 260)) {
        NSHostingView(rootView: MarksScene())
    }

    static let all = [components, sidebarA, marks]

    /// The scene a launch with no `--scene` shows.
    static let fallback = components

    static func named(_ name: String) -> GalleryScene? { all.first { $0.name == name } }
}
#endif
