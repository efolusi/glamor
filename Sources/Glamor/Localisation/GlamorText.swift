import Foundation

/// The words the library says itself: VoiceOver names, tooltips and the defaults of public arguments.
/// They live in `Resources/Localizable.xcstrings` (en and id) and follow the person's language.
/// Words a caller owns (a title, a placeholder, a row's name) are never here: the caller passes them.
enum GlamorText {
    /// One case per catalog key. `LocalisationTests` fails when a case has no en or id text, when a key in
    /// the catalog has no case, or when a source file says a user-facing word outside this list.
    enum Key: String, CaseIterable {
        case copy = "copy.action", copied = "copy.done"
        case clearSearch = "clear.search", clearFilter = "clear.filter"
        case more = "more.label", moreFor = "more.labelFor"
        case chipAll = "chip.all", sheetClose = "sheet.close"
        case working = "status.working", running = "status.running", failed = "status.failed", done = "status.done"
        case warning = "status.warning", error = "status.error", note = "status.note", problem = "status.problem"
        case percent = "progress.percent"
        case splitHelp = "split.help", splitAction = "split.action", splitHint = "split.hint"
        case splitTipSmallest = "split.tipSmallest", splitTipLargest = "split.tipLargest"
        case splitValueAtLeast = "split.valueAtLeast", splitValueRange = "split.valueRange"
        case skeletonItemName = "skeleton.itemName", skeletonDetailLine = "skeleton.detailLine"
        case themeToDark = "theme.toDark", themeToLight = "theme.toLight"
    }

    /// The languages the catalog ships.
    static let languages = ["en", "id"]

    /// The bundle holding `language`'s text; nil asks for the person's own language (as the system picks it).
    private static func bundle(for language: String?) -> Bundle {
        let wanted = language.map { [$0] } ?? Locale.preferredLanguages
        guard let best = Bundle.preferredLocalizations(from: Bundle.module.localizations, forPreferences: wanted).first,
              let path = Bundle.module.path(forResource: best, ofType: "lproj"),
              let found = Bundle(path: path) else { return Bundle.module }
        return found
    }

    /// The text of `key` in `language` (nil: the person's language). A key with no text returns the key itself,
    /// which `LocalisationTests` makes impossible to ship.
    static func string(_ key: Key, language: String? = nil) -> String {
        bundle(for: language).localizedString(forKey: key.rawValue, value: nil, table: nil)
    }

    /// The text of `key` with its `%` placeholders filled by `arguments`, numbers written for the language.
    static func string(_ key: Key, language: String? = nil, _ arguments: CVarArg...) -> String {
        let b = bundle(for: language)
        let locale = Locale(identifier: b.preferredLocalizations.first ?? "en")
        return String(format: b.localizedString(forKey: key.rawValue, value: nil, table: nil), locale: locale, arguments: arguments)
    }
}
