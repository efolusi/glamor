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

    // MARK: The code gives the visual order

    private func sidebarBody() throws -> String {
        let text = try read("Sources/Glamor/macOS/Sidebar.swift")
        let start = try #require(text.range(of: "public var body: some View {"))
        let end = try #require(text.range(of: "/// Where the traffic lights sit"))
        return String(text[start.lowerBound..<end.lowerBound])
    }

    /// The cause (run 3, `Tab stops found`): the Tab order follows position on screen, and the rows below the fold are lower than
    /// the pinned footer. The scrolling rows are one focus section and the footer another, so focus visits all the rows before
    /// the footer, whatever their position; the sections themselves are ordered by position, top to bottom.
    @Test func theScrollingRowsAreOneFocusSection() throws {
        let body = try sidebarBody()
        let scroll = try #require(body.range(of: "ScrollView {"))
        let hairline = try #require(body.range(of: "Hairline()"))
        #expect(body[scroll.lowerBound..<hairline.lowerBound].contains(".focusSection()"),
                "the ScrollView and its rows are one section, so rows below the fold are not ordered against the footer")
    }

    /// The section is drawn round the footer's rows, not round their padding: the divider (the sidebar's full height, which ends at
    /// the same bottom edge as the padded footer) must not tie with it.
    @Test func theFooterIsItsOwnFocusSectionRoundItsRowsAndAfterTheContent() throws {
        let body = try sidebarBody()
        #expect(body.contains("footer.focusSection().padding(G.Row.listInset)"))
        let scroll = try #require(body.range(of: "ScrollView {"))
        let footer = try #require(body.range(of: "footer.focusSection()"))
        #expect(scroll.lowerBound < footer.lowerBound, "the footer is declared after the content in the view tree")
    }

    /// The divider is the last stop: it is declared after the footer (an overlay on the whole column), and the doc says the order.
    @Test func theDividerIsDeclaredAfterTheFooterAndTheDocNamesTheOrder() throws {
        let body = try sidebarBody()
        let footer = try #require(body.range(of: "footer.focusSection()"))
        let divider = try #require(body.range(of: "SplitDivider("))
        #expect(footer.lowerBound < divider.lowerBound)
        let text = try read("Sources/Glamor/macOS/Sidebar.swift")
        #expect(text.contains("Tab order: Hide, Search, every row top to bottom, the footer, then the divider"))
    }
}
#endif
