#if os(macOS)
import AppKit
#if DEBUG
@testable import Glamor   // IncreasedContrast.forced is internal; only the debug build used by scripts/check-window.sh needs it
#else
import Glamor
#endif

@MainActor
final class Delegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let scene: GalleryScene

    init(scene: GalleryScene) {
        self.scene = scene
        super.init()
    }

    func applicationDidFinishLaunching(_ note: Notification) {
        window = NSWindow(contentRect: NSRect(origin: CGPoint(x: 200, y: 200), size: scene.size), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.title = Words.text("window.title")
        window.contentView = scene.makeContent()
        if let name = Options.appearance { NSApp.appearance = NSAppearance(named: name) }
        #if DEBUG
        if Options.increaseContrast { IncreasedContrast.forced = true }
        #endif
        if Options.logActivations {
            var count = 0
            NotificationCenter.default.addObserver(forName: .galleryActivated, object: nil, queue: .main) { [weak self] note in
                count += 1
                MainActor.assumeIsolated { self?.window.title = "\(Words.text("window.title")) | \(note.object as? String ?? "") | \(count)" }
            }
        }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        guard let dir = ProcessInfo.processInfo.environment["GLAMOR_GALLERY_SHOTS"] else { return }
        Task { @MainActor in
            for (name, appearance) in [("light", NSAppearance.Name.aqua), ("dark", .darkAqua)] {
                NSApp.appearance = NSAppearance(named: appearance)
                try? await Task.sleep(for: .milliseconds(800))
                self.save(to: URL(fileURLWithPath: dir).appendingPathComponent("glamor-app-\(self.scene.name)-\(name).png"))
            }
            NSApp.terminate(nil)
        }
    }

    private func save(to url: URL) {
        guard let view = window.contentView, let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return }
        view.cacheDisplay(in: view.bounds, to: rep)
        try? rep.representation(using: .png, properties: [:])?.write(to: url)
        let focused = window.firstResponder.map { String(describing: type(of: $0)) } ?? "none"
        print("saved \(url.lastPathComponent); first responder: \(focused)")
    }
}
#endif
