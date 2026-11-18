import Glamor
import Testing

/// Text from a server is shown only after DisplayText takes out what could hide or reorder it.
struct DisplayTextTests {
    @Test func escapeCodesAndDirectionOverridesAreRemoved() {
        #expect(DisplayText.clean("ok\u{1B}[31mred") == "okred")
        #expect(!DisplayText.clean("a\u{202E}b").unicodeScalars.contains("\u{202E}"))
    }
}
