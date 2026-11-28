#if os(macOS)
import Foundation
import Testing
@testable import Glamor

/// The keyboard order of the Mac sidebar (WCAG 2.4.3). Run 3 of v0.4.0 walked Tab through the sidebar and found
/// `... Komando's own > Settings > Snippet > Sidebar width > Credential ...`: macOS orders Tab stops by where they
/// are on screen, and the rows below the 680 pt fold sit lower than the pinned footer, so focus jumped to the footer
/// and back into the list. The order a keyboard user needs is the visual one: Hide, Search, every row top to bottom,
/// the pinned footer, then the divider (the last stop of the sidebar, before the page it sizes).
/// The window check is the owner's sitting; these keep the source and the check's expected list from drifting.
@MainActor
struct SidebarFocusOrderTests {
    private static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

    private func read(_ path: String) throws -> String {
        try String(contentsOf: Self.root.appendingPathComponent(path), encoding: .utf8)
    }

    private func body(of function: String, in text: String) throws -> String {
        let start = try #require(text.range(of: "func \(function)("), "no func \(function) in WindowCheck.swift")
        let rest = text[start.lowerBound...]
        let end = rest.dropFirst().range(of: "\n}\n")
        return String(rest[..<(end?.upperBound ?? rest.endIndex)])
    }

    // MARK: The divider is the last stop (the window check's expected list)

    /// The check names the divider by the words VoiceOver reads for it, which are the library's English string.
    @Test func theWindowCheckNamesTheDividerByTheLibrarysEnglishWords() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains(#"let sidebarDividerName = "Sidebar width""#))
        #expect(GlamorText.string(.sidebarWidth, language: "en") == "Sidebar width")
    }

    /// The divider is not a listed control (its role is AXUnknown): a scene names its last stop and the check looks it up
    /// in any role, as the marks and the switch are, then expects it as the last stop of the turn, after the footer.
    @Test func theSidebarAScenesTabOrderEndsOnTheDivider() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains("var lastStop: String? = nil"))
        #expect(check.contains("lastStop: sidebarDividerName"))
        let keys = try body(of: "keysMode", in: check)
        #expect(keys.contains("spokenName($0) == lastStop"), "found in any role, by what it reads")
        #expect(keys.contains("order + "), "the expected order holds the divider after the listed controls")
        #expect(keys.contains(#"note("divider-ax""#), "the NOTE prints the role, subrole and frame it was read with")
    }

    @Test func theDividerStandsAfterTheFooterInTheWalkAndTheLineSaysSo() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        let keys = try body(of: "keysMode", in: check)
        #expect(keys.contains("the divider follows the footer"))
        #expect(keys.contains(#"check("tab-order""#))
    }
}
#endif
