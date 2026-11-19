#if os(macOS)
import AppKit
import Glamor
import SwiftUI

// A small Mac app that shows Glamor's components in a real window, for a person to look at.
// It is not part of the library. Run: `swift run GlamorGallery`, or with GLAMOR_GALLERY_SHOTS=<dir>
// to save the window in light and dark, then quit.

struct Gallery: View {
    @State private var choice = "Daily"
    @FocusState private var saveFocused: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: G.Space.s16) {
            CardList {
                ListRow(action: {}) { Text("web-1") }
                ListRow(selected: true, action: {}) { Text("db-primary (selected)") }
                ListRow(action: {}) { Text("queue-3") }
            }
            HStack(spacing: G.Space.s16) {
                Button("Save") {}.buttonStyle(PrimaryButtonStyle()).focused($saveFocused)
                Button("Cancel") {}.buttonStyle(SecondaryButtonStyle())
                MenuPicker(title: choice, selection: $choice) {
                    Text("Daily").tag("Daily"); Text("Weekly").tag("Weekly")
                }
                MoreMenu(label: "web-1") { Button("Rename") {}; Button("Remove") {} }
            }
            ProgressBar(value: 0.6)
        }
        .textStyle(.body)
        .foregroundStyle(G.text)
        .padding(G.Space.s24)
        .frame(width: 460)
        .background(G.panel)
        .onAppear { saveFocused = true }
    }
}

@MainActor
final class Delegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    func applicationDidFinishLaunching(_ note: Notification) {
        window = NSWindow(contentRect: NSRect(x: 200, y: 200, width: 460, height: 320), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.title = "Glamor gallery"
        window.contentView = NSHostingView(rootView: Gallery())
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        guard let dir = ProcessInfo.processInfo.environment["GLAMOR_GALLERY_SHOTS"] else { return }
        Task { @MainActor in
            for (name, appearance) in [("light", NSAppearance.Name.aqua), ("dark", .darkAqua)] {
                NSApp.appearance = NSAppearance(named: appearance)
                try? await Task.sleep(for: .milliseconds(800))
                self.save(to: URL(fileURLWithPath: dir).appendingPathComponent("glamor-app-\(name).png"))
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

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = Delegate()
    app.delegate = delegate
    app.setActivationPolicy(.regular)
    app.run()
}
#endif
