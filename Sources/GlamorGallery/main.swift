#if os(macOS)
import AppKit

// A small Mac app that shows Glamor's components in a real window, for a person to look at.
// It is not part of the library. Run: `swift run GlamorGallery [--scene <name>]`, or with GLAMOR_GALLERY_SHOTS=<dir>
// to save the window in light and dark, then quit. The launch arguments are in Options.swift, the scenes in Scenes/.

MainActor.assumeIsolated {
    var scene = GalleryScenes.fallback
    if let name = Options.sceneName {
        guard let named = GalleryScenes.named(name) else {
            FileHandle.standardError.write(Data("unknown scene \"\(name)\"; the scenes are \(GalleryScenes.all.map(\.name).joined(separator: ", "))\n".utf8))
            exit(64)
        }
        scene = named
    }
    let app = NSApplication.shared
    let delegate = Delegate(scene: scene)
    app.delegate = delegate
    app.setActivationPolicy(.regular)
    app.run()
}
#endif
