import Glamor
import Testing

/// Text from a server is shown only after DisplayText takes out what could hide or reorder it.
struct DisplayTextTests {
    @Test func escapeCodesAndDirectionOverridesAreRemoved() {
        #expect(DisplayText.clean("ok\u{1B}[31mred") == "okred")
        #expect(!DisplayText.clean("a\u{202E}b").unicodeScalars.contains("\u{202E}"))
    }
}

/// Edge cases: nothing in, C0 controls, line endings, an escape that never ends.
struct DisplayTextEdgeTests {
    @Test func emptyStaysEmpty() {
        #expect(DisplayText.clean("") == "")
        #expect(DisplayText.line("") == "")
    }

    @Test func c0ControlsAreRemovedButLineBreaksAndTabsStay() {
        #expect(DisplayText.clean("a\u{00}b\u{07}c\u{08}d\u{7F}e") == "abcde")
        #expect(DisplayText.clean("a\tb\nc") == "a\tb\nc")
    }

    @Test func carriageReturnsBecomeOneLineBreak() {
        #expect(DisplayText.clean("a\r\nb") == "a\nb")
        #expect(DisplayText.clean("a\rb") == "a\nb")
        #expect(DisplayText.clean("a\u{2028}b") == "a\nb")
    }

    @Test func aLineHasNoBreaksOrTabs() {
        #expect(DisplayText.line("\nweb-1\tprod\n") == "web-1 prod")
    }

    @Test func anUnendedControlStringLeavesAMarkAndKeepsTheText() {
        #expect(DisplayText.clean("a\u{1B}]title") == "a\u{FFFD}title")
    }
}
