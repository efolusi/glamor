import Foundation
import SwiftUI
import Testing
import Glamor

/// What VoiceOver hears, through the public API only.
struct AccessTests {
    #if os(macOS)
    @Test func theMoreButtonSaysWhatItIsFor() {
        #expect(MoreMenuWords.label(nil) == "More")
        #expect(MoreMenuWords.label("") == "More")
        #expect(MoreMenuWords.label("web-1") == "More for web-1")
        #expect(MoreMenuWords.label("the pane on web-1") == "More for the pane on web-1")
    }
    #endif

    #if os(macOS)
    @Test func aBannerSaysItsKind() {
        #expect(Banner<EmptyView>.spokenKind(.success) == "Done")
        #expect(Banner<EmptyView>.spokenKind(.warning) == "Warning")
        #expect(Banner<EmptyView>.spokenKind(.danger) == "Error")
        #expect(Banner<EmptyView>.spokenKind(.info) == "Note")
    }
    #endif

    /// `.icon(…)` hides its symbol from VoiceOver, so a label put on the symbol afterwards would never be read.
    /// A symbol that means something takes `icon(_:label:)`; a symbol in a button is named by the button.
    @Test func noHiddenIconCarriesALabelOfItsOwn() throws {
        let sources = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Sources/Glamor")
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
