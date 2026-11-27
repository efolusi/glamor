#if os(macOS)
import AppKit
#if DEBUG
@testable import Glamor   // IncreasedContrast.forced is internal; only the debug build used by scripts/check-window.sh needs it
#else
import Glamor
#endif
import SwiftUI

// A small Mac app that shows Glamor's components in a real window, for a person to look at.
// It is not part of the library. Run: `swift run GlamorGallery`, or with GLAMOR_GALLERY_SHOTS=<dir>
// to save the window in light and dark, then quit.
//
// Launch arguments, for scripts/check-window.sh (they change only this app, never the system settings):
//   --appearance light|dark   the app's own appearance
//   --increase-contrast       draws the Increase contrast colours (IncreasedContrast.forced, debug builds only)
//   --open-sheet              opens a sheet at launch (scripts/check-window.sh reads its title as a heading)
//   --log-activations         puts the last activated control's name and a count in the window title, and prints
//                             the accessibility environment the views received
//
// SwiftUI's accessibilityReduceTransparency and colorSchemeContrast are read-only environment values, so they
// cannot be set from here, and the high-contrast NSAppearance names are not honoured for an app whose system
// setting is off: what the views received is printed, and the check script reports it.

struct Options {
    static let args = CommandLine.arguments
    static let increaseContrast = args.contains("--increase-contrast")
    static let logActivations = args.contains("--log-activations")
    static let openSheet = args.contains("--open-sheet")
    static var appearance: NSAppearance.Name? {
        guard let i = args.firstIndex(of: "--appearance"), i + 1 < args.count else { return nil }
        return args[i + 1] == "dark" ? .darkAqua : .aqua
    }
}

extension Notification.Name { static let galleryActivated = Notification.Name("glamor.gallery.activated") }

/// Records a control's name, so a script can see that Space or Return reached it.
func activated(_ name: String) {
    NotificationCenter.default.post(name: .galleryActivated, object: name)
}

/// Prints what SwiftUI hands the views, so a script can see which glass path Glamor will take.
struct EnvironmentProbe: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast
    var body: some View {
        Color.clear.onAppear {
            if Options.logActivations {
                print("environment: contrast=\(contrast == .increased ? "increased" : "standard") reduceTransparency=\(reduceTransparency)")
                fflush(stdout)
            }
        }
    }
}

/// The gallery's words, from its own catalog (`Resources/Localizable.xcstrings`, en and id). Start it with
/// `-AppleLanguages "(id)"` for Indonesian, or `-NSDoubleLocalizedStrings YES` to see every word twice as long.
enum Words {
    static func text(_ key: String) -> String { Bundle.module.localizedString(forKey: key, value: nil, table: nil) }
    static func text(_ key: String, _ argument: String) -> String { String(format: text(key), argument) }
}

/// A demo choice, named by its catalog key.
struct Period: Hashable {
    let titleKey: String
    var title: String { Words.text(titleKey) }
    static let daily = Period(titleKey: "period.daily")
    static let weekly = Period(titleKey: "period.weekly")
}

struct Gallery: View {
    /// A host name is data, not a word to translate.
    static let host = "web-1"
    @State private var choice = Period.daily
    @State private var segment = 0
    @State private var search = ""
    @State private var appearance = Appearance.light
    @State private var sheetShown = Options.openSheet
    @FocusState private var saveFocused: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: G.Space.s16) {
            CardList {
                ListRow(action: { activated(Gallery.host) }) { Text(verbatim: Gallery.host) }
                ListRow(selected: true, action: { activated("db-primary") }) { Text(Words.text("row.selected", "db-primary")) }
                ListRow(action: { activated("queue-3") }) { Text(verbatim: "queue-3") }
            }
            HStack(spacing: G.Space.s16) {
                Button(Words.text("action.save")) { activated("Save") }.buttonStyle(PrimaryButtonStyle()).focused($saveFocused)
                Button(Words.text("action.cancel")) { activated("Cancel") }.buttonStyle(SecondaryButtonStyle())
                MenuPicker(title: choice.title, selection: $choice) {
                    Text(Period.daily.title).tag(Period.daily); Text(Period.weekly.title).tag(Period.weekly)
                }
                MoreMenu(label: Gallery.host) {
                    Button(Words.text("action.rename")) { activated("Rename") }
                    Button(Words.text("action.remove")) { activated("Remove") }
                }
            }
            HStack(spacing: G.Space.s16) {
                Button(Words.text("action.deploy")) { activated("Deploy") }.glassMainAction(fallback: PrimaryButtonStyle())
                SegmentedControl(items: ["period.day", "period.week", "period.month"].map(Words.text), selection: $segment)
                ThemeSwitch(appearance: $appearance, words: .current)
            }
            SearchBar(placeholder: Words.text("search.hosts"), text: $search)
            Text(Words.text("toolbar.title")).textStyle(.caption).foregroundStyle(G.text2)
                .frame(maxWidth: .infinity, minHeight: G.Height.control32).glassBar()
                // A spinner with no label of its own: VoiceOver reads the library's "Working" (GL22).
                .overlay(alignment: .trailing) { SpinnerSlot(shown: true).padding(.trailing, G.Space.s12) }
            ProgressBar(value: 0.6)
        }
        .textStyle(.body)
        .foregroundStyle(G.text)
        .padding(G.Space.s24)
        .frame(width: 460)
        .background(G.panel)
        .onAppear { saveFocused = true }
        .onChange(of: segment) { activated("segment \(segment)") }
        .onChange(of: appearance) { activated("theme \(appearance)") }
        .background(EnvironmentProbe())
        .sheet(isPresented: $sheetShown) {
            SheetLayout(symbol: "desktopcomputer", title: Words.text("sheet.title")) {
                Text(Words.text("sheet.body"))
            } buttons: {
                Button(Words.text("action.cancel")) { sheetShown = false }
                    .buttonStyle(SecondaryButtonStyle()).keyboardShortcut(.cancelAction)
            }
        }
    }
}

@MainActor
final class Delegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    func applicationDidFinishLaunching(_ note: Notification) {
        window = NSWindow(contentRect: NSRect(x: 200, y: 200, width: 460, height: 460), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.title = Words.text("window.title")
        window.contentView = NSHostingView(rootView: Gallery())
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
