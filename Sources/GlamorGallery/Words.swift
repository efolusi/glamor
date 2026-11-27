#if os(macOS)
import Foundation

/// The gallery's words, from its own catalog (`Resources/Localizable.xcstrings`, en and id). Start it with
/// `-AppleLanguages "(id)"` for Indonesian, or `-NSDoubleLocalizedStrings YES` to see every word twice as long.
enum Words {
    static func text(_ key: String) -> String { Bundle.module.localizedString(forKey: key, value: nil, table: nil) }
    static func text(_ key: String, _ argument: String) -> String { String(format: text(key), argument) }
}
#endif
