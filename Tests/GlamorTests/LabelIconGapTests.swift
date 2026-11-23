import Foundation
import Testing
import Glamor

/// GL21: every control that pairs text with an icon takes the gap between them from one token,
/// `G.Space.labelIcon` (design-tokens space-2, 8). Not a literal, and not SwiftUI's default spacing.
struct LabelIconGapTests {
    @Test func theGapIsTheSpaceTwoToken() {
        #expect(G.Space.labelIcon == CGFloat(GlamorTokens.Length.space2))
        #expect(G.Space.labelIcon == 8)
    }

    /// The menu button first: its own chevron, drawn with the token, and the system's indicator off,
    /// because the system's indicator sits about 3 pt from the label.
    @Test func theMenuPickerDrawsItsOwnChevronAtTheTokenGap() throws {
        let text = try source("macOS/Controls.swift")
        let start = try #require(text.range(of: "public struct MenuPicker"))
        let end = try #require(text.range(of: "public struct SegmentedControl"))
        let picker = String(text[start.lowerBound..<end.lowerBound])
        #expect(picker.contains(".menuIndicator(.hidden)"))
        #expect(picker.contains("chevron.down"))
        #expect(LabelIconGap.violations(in: picker).isEmpty)
        #expect(picker.contains("spacing: G.Space.labelIcon"))
    }

    @Test func everyTextAndIconPairingInTheLibraryUsesTheToken() throws {
        var found = [String]()
        for file in try sourceFiles() {
            for violation in LabelIconGap.violations(in: file.text) { found.append("\(file.name): \(violation)") }
        }
        #expect(found.isEmpty, "use HStack(spacing: G.Space.labelIcon) for text and icon: \(found)")
    }

    // The scanner itself: it must fail on each way of getting the gap wrong.

    @Test func theScannerFlagsALiteralSpacing() {
        let code = #"HStack(spacing: 4) { Text(title); Image(systemName: "chevron.right") }"#
        #expect(LabelIconGap.violations(in: code).count == 1)
    }

    @Test func theScannerFlagsAnotherTokenThanTheLabelIconOne() {
        let code = #"HStack(spacing: G.Space.s4) { Text(title); Image(systemName: "chevron.right") }"#
        #expect(LabelIconGap.violations(in: code).count == 1)
    }

    @Test func theScannerFlagsTheSwiftUIDefault() {
        let code = #"HStack { Image(systemName: "star"); Text(title) }"#
        #expect(LabelIconGap.violations(in: code).count == 1)
    }

    @Test func theScannerFlagsALabelWithoutAStyle() {
        let code = #"Label { Text("x") } icon: { Image(systemName: "star") }"#
        #expect(LabelIconGap.violations(in: code).count == 1)
    }

    @Test func theScannerFlagsALabelStyleThatDrawsTheDefault() {
        let code = #"HStack { configuration.icon; configuration.title }"#
        #expect(LabelIconGap.violations(in: code).count == 1)
    }

    @Test func theScannerAcceptsTheToken() {
        let code = #"HStack(alignment: .center, spacing: G.Space.labelIcon) { Image(systemName: "star"); Text(title) }"#
        #expect(LabelIconGap.violations(in: code).isEmpty)
    }

    @Test func theScannerLeavesHStacksWithoutAnIconAlone() {
        let code = #"HStack(spacing: G.Space.s12) { Text(a); Text(b) }"#
        #expect(LabelIconGap.violations(in: code).isEmpty)
    }

    // MARK: Files

    private struct SourceFile { let name: String; let text: String }

    private var root: URL {
        URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }

    private func source(_ path: String) throws -> String {
        try String(contentsOf: root.appendingPathComponent("Sources/Glamor").appendingPathComponent(path), encoding: .utf8)
    }

    /// Every Glamor source file except the generated tokens.
    private func sourceFiles() throws -> [SourceFile] {
        let base = root.appendingPathComponent("Sources/Glamor")
        let urls = FileManager.default.enumerator(at: base, includingPropertiesForKeys: nil)?.compactMap { $0 as? URL } ?? []
        return try urls.filter { $0.pathExtension == "swift" && !$0.path.contains("/Generated/") }
            .map { SourceFile(name: $0.lastPathComponent, text: try String(contentsOf: $0, encoding: .utf8)) }
    }
}

/// Finds the places that put text beside an icon and checks their gap.
enum LabelIconGap {
    private static let icon = ["Image(systemName", "configuration.icon"]
    private static let text = ["Text(", "TextField(", "configuration.title"]

    static func violations(in raw: String) -> [String] {
        let code = raw.split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces).hasPrefix("//") ? "" : String($0) }.joined(separator: "\n")
        let chars = Array(code)
        var found = [String]()

        var from = code.startIndex
        while let hit = code.range(of: #"\bHStack\s*[({]"#, options: .regularExpression, range: from..<code.endIndex) {
            from = hit.upperBound
            let open = code.distance(from: code.startIndex, to: hit.upperBound) - 1
            // `HStack(arguments) { body }`, or `HStack { body }` with the default spacing.
            var arguments = "", inner = ""
            if chars[open] == "(" {
                guard let close = matching(chars, open), let body = closure(chars, after: close) else { continue }
                arguments = String(chars[(open + 1)..<close]); inner = String(chars[body])
            } else {
                guard let end = matching(chars, open) else { continue }
                inner = String(chars[(open + 1)..<end])
            }
            guard icon.contains(where: inner.contains), text.contains(where: inner.contains) else { continue }
            if !arguments.contains("spacing: G.Space.labelIcon") {
                found.append("HStack(\(arguments.trimmingCharacters(in: .whitespacesAndNewlines))) pairs text and an icon")
            }
        }

        from = code.startIndex
        while let hit = code.range(of: #"\bLabel\s*[({]"#, options: .regularExpression, range: from..<code.endIndex) {
            from = hit.upperBound
            let tail = String(code[hit.upperBound...].prefix(240))
            if !tail.contains(".labelStyle(") { found.append("Label without a labelStyle") }
        }
        return found
    }

    /// The index of the bracket that closes the one at `open`.
    private static func matching(_ chars: [Character], _ open: Int) -> Int? {
        let pairs: [Character: Character] = ["(": ")", "{": "}", "[": "]"]
        guard let closer = pairs[chars[open]] else { return nil }
        var depth = 0
        for i in open..<chars.count {
            if chars[i] == chars[open] { depth += 1 } else if chars[i] == closer { depth -= 1 }
            if depth == 0 { return i }
        }
        return nil
    }

    /// The range inside the `{ }` that directly follows `close`, if there is one.
    private static func closure(_ chars: [Character], after close: Int) -> Range<Int>? {
        var i = close + 1
        while i < chars.count, chars[i].isWhitespace { i += 1 }
        guard i < chars.count, chars[i] == "{", let end = matching(chars, i) else { return nil }
        return (i + 1)..<end
    }
}
