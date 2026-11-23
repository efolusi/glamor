import Foundation
import Testing

/// The window check (scripts/check-window.sh) measured four faults in the gallery window: the Daily menu button's
/// label and chevron 7 pt apart (the system re-laid out the label), Deploy and Daily exposing a 16 pt high area
/// for a 32 pt high button, a search field named only by its placeholder, and a ⋯ button with two names.
/// These pin the source shape that fixes each; the window check proves the result in a real window.
struct HitAreaAndNameTests {
    private func source(_ path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent("Sources/Glamor").appendingPathComponent(path), encoding: .utf8)
    }

    private func part(_ text: String, from start: String, to end: String) throws -> String {
        let a = try #require(text.range(of: start)), b = try #require(text.range(of: end))
        return String(text[a.lowerBound..<b.lowerBound])
    }

    @Test func theMenuPickerDrawsItsFaceOutsideTheSystemMenu() throws {
        let picker = try part(try source("macOS/Controls.swift"), from: "public struct MenuPicker", to: "public struct SegmentedControl")
        let menu = try #require(picker.range(of: "Menu {"))
        let chevron = try #require(picker.range(of: "chevron.down"))
        #expect(chevron.lowerBound < menu.lowerBound, "the chevron is drawn before, and outside, the Menu")
        #expect(picker.contains("label: { Color.clear"), "the Menu's own label is empty, so the system has nothing to re-lay out")
        #expect(picker.contains(".accessibilityLabel(title)"))
    }

    @Test func theMainActionTakesTheWholeButtonAsItsHitArea() throws {
        let style = try source("Glass/GlassMainActionStyle.swift")
        #expect(style.contains(".contentShape(shape)"))
        #expect(style.contains("G.Height.control32"))
    }

    @Test func aSearchFieldIsNamedByALabelEqualToItsPlaceholder() throws {
        let controls = try source("macOS/Controls.swift")
        #expect(try part(controls, from: "public struct SearchBar", to: "public struct MenuPicker").contains(".accessibilityLabel(placeholder)"))
        let lists = try source("macOS/Lists.swift")
        #expect(try part(lists, from: "public struct FilterField", to: "public enum MoreMenuWords").contains(".accessibilityLabel(placeholder)"))
    }

    @Test func theMoreMenuHasOneNameBecauseItsMenuLabelIsEmpty() throws {
        let more = try part(try source("macOS/Lists.swift"), from: "public struct MoreMenu", to: "    public init(size: CGFloat = G.Height.control28, label: String?")
        #expect(more.contains("label: { Color.clear }"))
        #expect(more.contains(".accessibilityLabel(MoreMenuWords.label(label))"))
    }
}
