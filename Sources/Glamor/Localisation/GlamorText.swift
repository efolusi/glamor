import Foundation

/// The words the library says itself: VoiceOver names, tooltips and the defaults of public arguments.
/// They live in `Resources/Localizable.xcstrings` (en and id) and follow the host app's language, then the person's.
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
        case markPro = "mark.pro", markProSpoken = "mark.proSpoken"
        case markSoon = "mark.soon", markSoonSpoken = "mark.soonSpoken"
        case sidebarLabel = "sidebar.label", sidebarHide = "sidebar.hide", sidebarWidth = "sidebar.width"
        case sidebarExpanded = "sidebar.expanded", sidebarCollapsed = "sidebar.collapsed"
    }

    /// The languages the catalog ships.
    static let languages = ["en", "id"]

    /// The catalog's language for a preference list (BCP 47 codes, best first, as `Locale.preferredLanguages` gives
    /// them): the first one the catalog has, else English. English is added at the end, so the fallback is explicit.
    static func code(preferences: [String]) -> String {
        Bundle.preferredLocalizations(from: Bundle.module.localizations, forPreferences: preferences + ["en"]).first ?? "en"
    }

    /// The catalog's language for a host app and a person. `host` is the app's own languages, ordered for this person
    /// (`Bundle.main.preferredLocalizations`): its first one the catalog has wins, so Glamor's words match the app's
    /// and an English-only app on a Mac set to Indonesian stays English. A host with none of them (a bare tool, an app
    /// in French only) leaves it to the person's list, `preferences`, and then to English.
    static func code(host: [String], preferences: [String]) -> String {
        for tag in host {
            if let language = Locale(identifier: tag).language.languageCode?.identifier, languages.contains(language) {
                return language
            }
        }
        return code(preferences: preferences)
    }

    /// The host app's languages, ordered for this person. Empty for an executable with no Info.plist and no `.lproj`
    /// of its own (the gallery under `swift run`), which then follows the person's list.
    static var hostLanguages: [String] {
        hostLanguages(localizations: Bundle.main.localizations, preferred: Bundle.main.preferredLocalizations)
    }

    /// `hostLanguages` for a given bundle answer, made testable. A bundle with no localizations still answers
    /// `preferredLocalizations` with ["en"]; that answer is dropped, so the person's list decides.
    static func hostLanguages(localizations: [String], preferred: [String]) -> [String] {
        localizations.isEmpty ? [] : preferred
    }

    /// The language code and the bundle holding its text. `language` names one (any BCP 47 code); nil follows the host
    /// app's languages, then the person's list, `preferences`.
    private static func resolve(_ language: String?, _ host: [String], _ preferences: [String]) -> (code: String, bundle: Bundle) {
        let code = language.map { Self.code(preferences: [$0]) } ?? Self.code(host: host, preferences: preferences)
        guard let path = Bundle.module.path(forResource: code, ofType: "lproj"), let found = Bundle(path: path) else {
            return (code, Bundle.module)
        }
        return (code, found)
    }

    /// The text of `key` in `language` (nil: the host app's language, then the person's system list). A key with no
    /// text returns the key itself, which `LocalisationTests` makes impossible to ship.
    static func string(_ key: Key, language: String? = nil) -> String {
        resolve(language, hostLanguages, Locale.preferredLanguages).bundle.localizedString(forKey: key.rawValue, value: nil, table: nil)
    }

    /// The text of `key` for an explicit host and preference list (what `string(_:language:)` does with nil, made
    /// testable). `host` defaults to none, which leaves it to `preferences`.
    static func string(_ key: Key, host: [String] = [], preferences: [String]) -> String {
        resolve(nil, host, preferences).bundle.localizedString(forKey: key.rawValue, value: nil, table: nil)
    }

    /// The text of `key` with its `%` placeholders filled by `arguments`, numbers written for the language.
    static func string(_ key: Key, language: String? = nil, _ arguments: CVarArg...) -> String {
        let found = resolve(language, hostLanguages, Locale.preferredLanguages)
        return String(format: found.bundle.localizedString(forKey: key.rawValue, value: nil, table: nil),
                      locale: Locale(identifier: found.code), arguments: arguments)
    }
}
