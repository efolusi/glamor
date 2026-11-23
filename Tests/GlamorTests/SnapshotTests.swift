#if os(macOS)
import AppKit
import Glamor
import SwiftUI
import Testing

/// Renders a few components to PNG for a person to look at: a list with a selected and a focused row,
/// a focused primary button and a ProgressBar, in light and dark. It runs only when
/// GLAMOR_SNAPSHOT_DIR names a folder, so a normal `swift test` skips it.
@MainActor
struct SnapshotTests {
    private var folder: URL? { ProcessInfo.processInfo.environment["GLAMOR_SNAPSHOT_DIR"].map { URL(fileURLWithPath: $0) } }

    private var gallery: some View {
        VStack(alignment: .leading, spacing: G.Space.s16) {
            CardList {
                ListRow(action: {}) { Text("web-1") }
                ListRow(selected: true, action: {}) { Text("db-primary (selected)") }
                Text("cache-eu (focused)").rowLook(focus: true, height: G.Height.row40 - 2 * G.Row.cardInset)
                ListRow(action: {}) { Text("queue-3") }
            }
            HStack(spacing: G.Space.s16) {
                Button("Save") {}.buttonStyle(PrimaryButtonStyle())
                    .focusRing(G.Radius.r8, isFocused: true)
                Button("Cancel") {}.buttonStyle(SecondaryButtonStyle())
            }
            HStack(spacing: G.Space.s16) {
                Button("Deploy") {}.glassMainAction(fallback: PrimaryButtonStyle())
                SegmentedControl(items: ["Day", "Week", "Month"], selection: .constant(1))
                ThemeSwitch(appearance: .constant(.light), words: .english)
            }
            SearchBar(placeholder: "Search hosts", text: .constant(""))
            VStack(alignment: .leading, spacing: G.Space.s8) {
                ProgressBar(value: 0.6)
                ProgressBar(value: 0.9, tone: G.warn)
                ProgressBar(value: 1, tone: G.ok)
            }
        }
        .textStyle(.body)
        .foregroundStyle(G.text)
        .padding(G.Space.s24)
        .frame(width: 420)
        .background(G.panel)
    }

    @Test(.enabled(if: ProcessInfo.processInfo.environment["GLAMOR_SNAPSHOT_DIR"] != nil), arguments: [false, true])
    func gallery(dark: Bool) throws {
        let folder = try #require(folder)
        var data: Data?
        NSAppearance(named: dark ? .darkAqua : .aqua)!.performAsCurrentDrawingAppearance {
            let renderer = ImageRenderer(content: gallery.environment(\.colorScheme, dark ? .dark : .light))
            renderer.scale = 2
            if let image = renderer.nsImage, let tiff = image.tiffRepresentation {
                data = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:])
            }
        }
        try #require(data).write(to: folder.appendingPathComponent("glamor-mac-\(dark ? "dark" : "light").png"))
    }
}
#endif
