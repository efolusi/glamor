#if os(macOS)
import AppKit

/// One thing the gallery window can show (`--scene <name>`). A scene is a name, the size of its window and the view that
/// fills it. scripts/window/WindowCheck.swift has a list of the same name that says which controls it must find.
struct GalleryScene {
    /// What follows `--scene`, and the key of the scene's list in scripts/window/WindowCheck.swift.
    let name: String
    /// The window's content size, in points.
    let size: CGSize
    /// The window's content view.
    let makeContent: @MainActor () -> NSView
}
#endif
