import Foundation

/// Reads a source file of the library as text, and a token's declaration out of it, for the tests that keep the
/// iOS tokens in lockstep with the Mac's. Plain text, so it runs in `swift test` on the Mac.
struct TokenSource {
    private var root: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }

    /// A file under `Sources/Glamor`.
    func source(_ path: String) throws -> String {
        try String(contentsOf: root.appendingPathComponent("Sources/Glamor").appendingPathComponent(path), encoding: .utf8)
    }

    /// A file under `Sources/Glamor` with its `//` and `///` comments cut, so a pin matches code and a comment cannot satisfy it.
    func code(_ path: String) throws -> String {
        try source(path).split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in line.range(of: "//").map { String(line[..<$0.lowerBound]) } ?? String(line) }
            .joined(separator: "\n")
    }

    /// The text after `static let <name>…=` up to a comment or the end of the line.
    func value(of name: String, in source: String) -> String? {
        guard let match = source.range(of: "static let \(name)\\b[^=\n]*=[^\n]*", options: .regularExpression) else { return nil }
        let line = String(source[match])
        let rhs = line.drop { $0 != "=" }.dropFirst()
        return rhs.components(separatedBy: "//")[0].trimmingCharacters(in: .whitespaces)
    }

    /// The body of `enum <name> {` up to its closing brace (declared at four spaces of indent in the token files).
    func block(_ name: String, in source: String) -> String? {
        guard let start = source.range(of: "enum \(name) \\{", options: .regularExpression) else { return nil }
        let rest = source[start.upperBound...]
        guard let end = rest.range(of: "\n    }") else { return nil }
        return String(rest[..<end.lowerBound])
    }
}
