import Foundation
import Testing

/// GL26: the accent is copper, 2.1 to 2.7:1 as a shape on a light ground, so a shape drawn with it carries
/// `G.accentEdge` (ContrastTests measure the pairs). These tests read the sources for where the rim is drawn
/// and for the two tokens that may never be a control's edge.
struct AccentEdgeSourceTests {
    private var root: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }

    private func source(_ path: String) throws -> String {
        try String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
    }

    @Test func theSolidMainButtonDrawsTheAccentEdgeAndFadesItWhenDisabled() throws {
        let buttons = try source("Sources/Glamor/macOS/Buttons.swift")
        #expect(buttons.contains(".strokeBorder(G.accentEdge.opacity(enabled ? 1 : G.Opacity.disabled)"))
    }

    @Test func theGlassMainActionDrawsTheAccentEdgeOnMacAndIOS() throws {
        let style = try source("Sources/Glamor/Glass/GlassMainActionStyle.swift")
        #expect(style.components(separatedBy: ".strokeBorder(G.accentEdge").count - 1 == 2)
    }

    @Test func theProgressBarFillDefaultsToTheAccentEdge() throws {
        let feedback = try source("Sources/Glamor/macOS/Feedback.swift")
        #expect(feedback.components(separatedBy: "tone: Color = G.accentEdge").count - 1 == 2)
        #expect(!feedback.contains("tone: Color = G.accent)"))
    }

    /// accent.warm (2.89:1 on the page) and accent.soft (1.83:1) are below 3:1 as shapes: text or decoration
    /// only, never a control's only edge. No view reads either today; one that starts to must decide which
    /// it is and change this test with the reason.
    @Test func noViewReadsAccentWarmOrAccentSoft() throws {
        let views = root.appendingPathComponent("Sources/Glamor")
        let files = try #require(FileManager.default.enumerator(at: views, includingPropertiesForKeys: nil))
        var readers: [String] = []
        for case let file as URL in files where file.pathExtension == "swift" && !file.path.contains("/Generated/") {
            let text = try String(contentsOf: file, encoding: .utf8)
            if text.contains("accentWarm") || text.contains("accentSoft") { readers.append(file.lastPathComponent) }
        }
        #expect(readers.isEmpty, "\(readers)")
    }
}
