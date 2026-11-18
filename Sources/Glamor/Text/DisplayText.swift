import Foundation

/// Text from a server or from komando, made safe to show. A name or a line of output can carry
/// terminal escape codes, control characters, or Unicode direction overrides that make it read
/// as something else ("Trojan Source"); none of them is shown.
public enum DisplayText {
    /// Output: escape sequences and control characters are removed; line breaks and tabs stay.
    /// A bare CR (progress bars, old Mac files) becomes a line break, so no text is lost or written
    /// over; the CR of a CRLF pair is dropped. U+2028 and U+2029 are drawn as line breaks, so they become one.
    public static func clean(_ s: String) -> String {
        guard s.unicodeScalars.contains(where: needsWork) else { return s }
        let a = Array(s.unicodeScalars)
        var out = String.UnicodeScalarView()
        var i = 0
        // After one control string with no end, later introducers only leave a mark: no rescan, no hidden text.
        var unterminated = false
        while i < a.count {
            let c = a[i]
            i += 1
            switch c.value {
            case 0x1B where i < a.count:
                switch a[i] {
                case "[": i = skipCSI(a, i + 1)
                case "]", "P", "^", "_", "X":
                    if unterminated { out.append(marker); i += 1 }
                    else if let end = skipString(a, i + 1) { i = end }
                    else { out.append(marker); unterminated = true; i += 1 }
                case "(", ")", "*", "+", "#", "%": i = min(a.count, i + 2)   // charset designations take one more
                default: i += 1
                }
            case 0x1B:
                break
            case 0x9B:
                i = skipCSI(a, i)
            case 0x9D, 0x90, 0x98, 0x9E, 0x9F:
                if unterminated { out.append(marker) }
                else if let end = skipString(a, i) { i = end }
                else { out.append(marker); unterminated = true }
            case 0x0D:
                if i >= a.count || a[i].value != 0x0A { out.append("\n") }
            case 0x2028, 0x2029:
                out.append("\n")
            case 0x0A, 0x09:
                out.append(c)
            default:
                if !isHidden(c) { out.append(c) }
            }
        }
        return String(out)
    }

    /// Shown where a control string starts but never ends, so the words after it stay visible and the
    /// person can see something was there.
    public static let marker: Unicode.Scalar = "\u{FFFD}"

    /// One line, for a name, a title or a menu item: line breaks and tabs become spaces, and a
    /// break at either end is dropped.
    public static func line(_ s: String) -> String {
        let c = clean(s)
        guard c.contains(where: { $0 == "\n" || $0 == "\t" }) else { return c }
        return c.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
            .replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "\t", with: " ")
    }

    /// What the approval card spells out: everything hidden, and also ZWNJ and ZWJ, because there the
    /// exact characters of a command matter more than how a word looks.
    public static func invisibleInCommand(_ c: Unicode.Scalar) -> Bool {
        isHidden(c) || c.value == 0x200C || c.value == 0x200D
    }

    private static func needsWork(_ c: Unicode.Scalar) -> Bool {
        c.value == 0x1B || c.value == 0x0D || isHidden(c)
    }

    /// C0 and C1 controls (other than line feed and tab), DEL, the bidirectional overrides,
    /// embeddings, isolates and marks, the zero-width space and word joiner, the byte order mark, and the
    /// Unicode line and paragraph separators (which `clean` turns into line breaks), and the tag characters.
    public static func isHidden(_ c: Unicode.Scalar) -> Bool {
        switch c.value {
        case 0x09, 0x0A: false
        case 0x00...0x1F, 0x7F...0x9F: true
        case 0x202A...0x202E, 0x2066...0x2069, 0x200E, 0x200F, 0x061C: true
        // Zero-width space, word joiner, BOM. ZWNJ and ZWJ stay: they cannot reorder text, and
        // emoji sequences and Persian and Indic words need them.
        case 0x200B, 0x2060, 0xFEFF: true
        case 0x2028, 0x2029: true
        // Other default-ignorable characters that draw nothing: the Unicode tag characters (which can carry
        // hidden instructions to a model), the soft hyphen, the combining grapheme joiner, the invisible
        // math operators, the Mongolian vowel separator and the Hangul fillers.
        case 0xE0000...0xE007F, 0x00AD, 0x034F, 0x2061...0x2064, 0x180E, 0x115F, 0x1160, 0x3164, 0xFFA0: true
        default: false
        }
    }

    /// Parameters and intermediates up to the final byte (0x40–0x7E). Returns the index after it; a
    /// malformed sequence keeps what follows.
    private static func skipCSI(_ a: [Unicode.Scalar], _ start: Int) -> Int {
        var i = start
        while i < a.count {
            let v = a[i].value
            if (0x40...0x7E).contains(v) { return i + 1 }
            if !(0x20...0x3F).contains(v) { return i }
            i += 1
        }
        return i
    }

    /// Up to BEL, ST (`ESC \`) or the 8-bit ST. Returns the index after the end, or nil when the string
    /// never ends.
    private static func skipString(_ a: [Unicode.Scalar], _ start: Int) -> Int? {
        var i = start
        while i < a.count {
            switch a[i].value {
            case 0x07, 0x9C: return i + 1
            case 0x1B: return min(a.count, i + 2)
            default: i += 1
            }
        }
        return nil
    }
}
