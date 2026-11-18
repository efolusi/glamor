import Foundation
import SwiftUI
import Testing
@testable import Komando

/// The design system's shared pieces: the terminal palette as numbers, and what VoiceOver hears.
/// Seed note: still imports the Komando module name from the apps seed; retarget when Glamor has its own package.
struct DesignSystemAccessTests {
    /// Every token in tokens.json that has a light and a dark value, by name.
    private func pairs() throws -> [String: (light: String, dark: String)] {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("tokens.json")
        var found = [String: (light: String, dark: String)]()
        func walk(_ any: Any) {
            if let d = any as? [String: Any] {
                if let name = d["name"] as? String, let v = d["value"] as? [String: String], let l = v["light"], let k = v["dark"] {
                    found[name] = (l, k)
                }
                d.values.forEach(walk)
            } else if let a = any as? [Any] { a.forEach(walk) }
        }
        walk(try JSONSerialization.jsonObject(with: Data(contentsOf: url)))
        return found
    }

    private func hex(_ n: UInt32) -> String { String(format: "#%06x", n) }

    @Test func theTerminalPaletteIsTheOneInTheDesignTokens() throws {
        let tokens = try pairs()
        let light = K.Terminal.light, dark = K.Terminal.dark
        #expect(light.ansi.count == 16)
        #expect(dark.ansi.count == 16)
        #expect(tokens["term-bg"]?.light == hex(light.background))
        #expect(tokens["term-bg"]?.dark == hex(dark.background))
        let index = ["ansi-black": 0, "ansi-red": 1, "ansi-green": 2, "ansi-yellow": 3, "ansi-blue": 4,
                     "ansi-magenta": 5, "ansi-cyan": 6, "ansi-bright-black": 8]
        for (name, i) in index {
            #expect(tokens[name]?.light == hex(light.ansi[i]), "\(name) light")
            #expect(tokens[name]?.dark == hex(dark.ansi[i]), "\(name) dark")
        }
        // term-selection is the cursor color at this opacity ("#1659ff33" is 20%, "#6090ff40" is 25%).
        #expect(tokens["term-selection"]?.light == hex(light.cursor) + String(format: "%02x", Int((light.selectionOpacity * 255).rounded())))
        #expect(tokens["term-selection"]?.dark == hex(dark.cursor) + String(format: "%02x", Int((dark.selectionOpacity * 255).rounded())))
        #expect(K.Terminal.palette(dark: true) == dark)
        #expect(K.Terminal.palette(dark: false) == light)
    }

    @Test func theMoreButtonSaysWhatItIsFor() {
        #expect(MoreMenuWords.label(nil) == "More")
        #expect(MoreMenuWords.label("") == "More")
        #expect(MoreMenuWords.label("web-1") == "More for web-1")
        #expect(MoreMenuWords.label("the pane on web-1") == "More for the pane on web-1")
    }

    @Test func aBannerSaysItsKind() {
        #expect(Banner<EmptyView>.spokenKind(.success) == "Done")
        #expect(Banner<EmptyView>.spokenKind(.warning) == "Warning")
        #expect(Banner<EmptyView>.spokenKind(.danger) == "Error")
        #expect(Banner<EmptyView>.spokenKind(.info) == "Note")
    }

    /// `.icon(…)` hides its symbol from VoiceOver, so a label put on the symbol afterwards would never be read.
    /// A symbol that means something takes `icon(_:label:)`; a symbol in a button is named by the button.
    @Test func noHiddenIconCarriesALabelOfItsOwn() throws {
        let sources = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Sources/DesignSystem")
        var wrong = [String]()
        let files = FileManager.default.enumerator(at: sources, includingPropertiesForKeys: nil)?.compactMap { $0 as? URL } ?? []
        #expect(files.count > 5)
        for file in files where file.pathExtension == "swift" {
            let lines = try String(contentsOf: file, encoding: .utf8).components(separatedBy: "\n")
            for (n, line) in lines.enumerated() {
                guard let at = line.range(of: ".icon("), !line.contains("func icon"), !line.contains("label:") else { continue }
                // The symbol's own modifiers: the rest of the line up to a closing brace, and the lines after it
                // that start with a dot.
                var chain = String(line[at.lowerBound...])
                if let brace = chain.firstIndex(of: "}") { chain = String(chain[..<brace]) } else {
                    var next = n + 1
                    while next < lines.count, lines[next].trimmingCharacters(in: .whitespaces).hasPrefix(".") {
                        chain += lines[next]
                        next += 1
                    }
                }
                if chain.contains(".accessibilityLabel(") && !chain.contains(".accessibilityElement(") {
                    wrong.append("\(file.lastPathComponent):\(n + 1)")
                }
            }
        }
        #expect(wrong.isEmpty, "use icon(_:label:) here: \(wrong)")
    }
}
