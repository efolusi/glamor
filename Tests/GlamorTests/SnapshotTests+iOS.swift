#if os(iOS)
import Glamor
import SwiftUI
import Testing
import UIKit

/// The iOS gallery for a person to look at: icon tiles, status dots, pills and severity marks in light
/// and dark. It runs only when GLAMOR_SNAPSHOT_DIR names a folder (pass it with SIMCTL_CHILD_ in front).
@MainActor
struct SnapshotTestsIOS {
    private var gallery: some View {
        VStack(alignment: .leading, spacing: G.Space.s12) {
            HStack(spacing: G.Space.s12) {
                IconTile(symbol: "server.rack")
                IconTile(symbol: "cylinder.split.1x2", tint: G.ok)
                IconTile(symbol: "plus")
            }
            HStack(spacing: G.Space.s8) {
                StatusDot(color: G.ok); Pill(text: "Running", color: G.ok)
                StatusDot(color: G.warn); Pill(text: "Degraded", color: G.warn)
                StatusDot(color: G.danger); Pill(text: "Stopped", color: G.danger)
            }
            HStack(spacing: G.Space.s8) { Pill(mark: .pro); Pill(mark: .soon) }
            HStack(spacing: G.Space.s8) {
                SeverityMark(problem: true); Text("A problem").foregroundStyle(G.text)
                SeverityMark(problem: false); Text("A warning").foregroundStyle(G.text2)
            }
        }
        .padding(G.Space.s12)
        .frame(width: 360, alignment: .leading)
        .background(G.card)
    }

    @Test(.enabled(if: ProcessInfo.processInfo.environment["GLAMOR_SNAPSHOT_DIR"] != nil), arguments: [false, true])
    func gallery(dark: Bool) throws {
        let folder = URL(fileURLWithPath: try #require(ProcessInfo.processInfo.environment["GLAMOR_SNAPSHOT_DIR"]))
        let renderer = ImageRenderer(content: gallery.environment(\.colorScheme, dark ? .dark : .light))
        renderer.scale = 3
        let traits = UITraitCollection { $0.userInterfaceStyle = dark ? .dark : .light }
        var png: Data?
        traits.performAsCurrent { png = renderer.uiImage?.pngData() }
        try #require(png).write(to: folder.appendingPathComponent("glamor-ios-\(dark ? "dark" : "light").png"))
    }
}
#endif
