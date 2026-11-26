import Foundation
import SwiftUI
import Testing
@testable import Glamor

/// GL14: every word the library says itself is in a String Catalog with en and id, and no source file says a
/// user-facing word any other way. The gallery has its own catalog and the same rules.
struct LocalisationTests {
    private static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

    /// Keys whose English and Indonesian text may be the same word (a loan word, a name). Empty today: an entry here is a
    /// decision, written with its reason, never a way to silence the check.
    private static let sameInBothLanguages: Set<String> = []

    private struct Entry {
        let key: String
        let values: [String: String]
    }

    private func catalog(_ path: String) throws -> [Entry] {
        let data = try Data(contentsOf: Self.root.appendingPathComponent(path))
        let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(json["sourceLanguage"] as? String == "en")
        let strings = try #require(json["strings"] as? [String: [String: Any]])
        return strings.map { key, entry in
            let locs = entry["localizations"] as? [String: [String: Any]] ?? [:]
            var values = [String: String]()
            for (lang, loc) in locs {
                guard let unit = loc["stringUnit"] as? [String: String], unit["state"] == "translated" else { continue }
                values[lang] = unit["value"]
            }
            return Entry(key: key, values: values)
        }.sorted { $0.key < $1.key }
    }

    /// `%@`, `%lld`, `%1$lld`: the placeholders of a format, in a form that ignores their order.
    private func placeholders(_ text: String) -> [String] {
        let pattern = try! NSRegularExpression(pattern: "%(?:\\d+\\$)?(?:lld|@|d|f|s)")
        let found = pattern.matches(in: text, range: NSRange(text.startIndex..., in: text)).map { String(text[Range($0.range, in: text)!]) }
        // Strip the position: "%1$lld" and "%lld" are the same kind of argument.
        return found.map { $0.replacingOccurrences(of: "\\d+\\$", with: "", options: .regularExpression) }.sorted()
    }

    private func checkComplete(_ entries: [Entry], named name: String) {
        #expect(!entries.isEmpty, "\(name) has no strings")
        for entry in entries {
            for lang in ["en", "id"] {
                let value = entry.values[lang]
                #expect(value?.isEmpty == false, "\(name): \(entry.key) has no \(lang) text")
                #expect(value?.contains("\u{2014}") == false && value?.contains("\u{2013}") == false, "\(name): \(entry.key) \(lang) has a dash")
            }
            if let en = entry.values["en"], let id = entry.values["id"] {
                #expect(placeholders(en) == placeholders(id), "\(name): \(entry.key) en and id have different placeholders")
                #expect(en != id || Self.sameInBothLanguages.contains(entry.key), "\(name): \(entry.key) id is the English text; translate it, or list the key in sameInBothLanguages with the reason")
            }
            #expect(Set(entry.values.keys) == ["en", "id"], "\(name): \(entry.key) has languages \(entry.values.keys.sorted())")
        }
    }

    // MARK: Library catalog

    @Test func everyLibraryStringHasEnglishAndIndonesian() throws {
        checkComplete(try catalog("Sources/Glamor/Resources/Localizable.xcstrings"), named: "Glamor")
    }

    @Test func theCatalogAndTheKeyListAgree() throws {
        let inCatalog = Set(try catalog("Sources/Glamor/Resources/Localizable.xcstrings").map(\.key))
        let inCode = Set(GlamorText.Key.allCases.map(\.rawValue))
        #expect(inCatalog == inCode, "only in the catalog: \(inCatalog.subtracting(inCode).sorted()); only in code: \(inCode.subtracting(inCatalog).sorted())")
    }

    @Test func everyKeyIsUsedBySomeSource() throws {
        var used = Set<String>()
        for file in try sourceFiles("Sources/Glamor") where file.lastPathComponent != "GlamorText.swift" {
            let text = try String(contentsOf: file, encoding: .utf8)
            for key in GlamorText.Key.allCases {
                // `[,)]` after the key: `.more` must not be counted for `.moreFor`.
                let call = try NSRegularExpression(pattern: "GlamorText\\.string\\(\\.\(key)\\s*[,)]")
                if call.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil { used.insert(key.rawValue) }
            }
        }
        let unused = Set(GlamorText.Key.allCases.map(\.rawValue)).subtracting(used)
        #expect(unused.isEmpty, "no source uses these catalog strings: \(unused.sorted())")
    }

    @Test func theBuiltBundleHoldsBothLanguagesForEveryKey() throws {
        for key in GlamorText.Key.allCases {
            let entry = try #require(try catalog("Sources/Glamor/Resources/Localizable.xcstrings").first { $0.key == key.rawValue })
            for lang in GlamorText.languages {
                // `%@` takes a string, the other placeholders a number; a format given a wrong kind of argument crashes.
                let want = try #require(entry.values[lang])
                let locale = Locale(identifier: lang)
                let shown: String, expected: String
                if want.contains("%@") {
                    shown = GlamorText.string(key, language: lang, "web-1")
                    expected = String(format: want, locale: locale, "web-1")
                } else {
                    shown = GlamorText.string(key, language: lang, 1, 2, 3)
                    expected = String(format: want, locale: locale, 1, 2, 3)
                }
                #expect(shown != key.rawValue, "\(key.rawValue) is not in the built \(lang) bundle")
                #expect(shown == expected, "\(key.rawValue) \(lang) differs from the catalog")
            }
        }
    }

    @Test func aLanguageTheCatalogLacksFallsBackToEnglish() {
        #expect(GlamorText.string(.copy, language: "fr") == "Copy")
        #expect(GlamorText.string(.copy, language: "id-ID") == "Salin")
    }

    /// The `.strings` files the targets ship are what scripts/generate-strings.py writes from the catalog. A toolchain that
    /// does not compile a .xcstrings (macos-26 CI, Swift 6.3.3, the native build system) still gets every word.
    @Test func theShippedStringsFilesMatchTheCatalogs() throws {
        for folder in ["Sources/Glamor/Resources", "Sources/GlamorGallery/Resources"] {
            let entries = try catalog("\(folder)/Localizable.xcstrings")
            for lang in ["en", "id"] {
                let file = Self.root.appendingPathComponent("\(folder)/\(lang).lproj/Localizable.strings")
                let shipped = try #require(NSDictionary(contentsOf: file) as? [String: String], "\(folder)/\(lang).lproj/Localizable.strings is missing or unreadable; run scripts/generate-strings.py")
                let wanted = Dictionary(uniqueKeysWithValues: entries.map { ($0.key, $0.values[lang] ?? "") })
                #expect(shipped == wanted, "\(folder)/\(lang).lproj is out of date; run scripts/generate-strings.py")
            }
        }
    }

    #if os(macOS)
    /// GL22: a spinner built without a label is still named for VoiceOver, in the person's language.
    @Test func aSpinnerWithNoLabelIsNamedWorking() {
        let want = GlamorText.string(.working)
        #expect(!want.isEmpty && want != GlamorText.Key.working.rawValue)
        #expect(SpinnerSlot(shown: true).label == want)
        #expect(BusyLine(isBusy: true, text: "x") { EmptyView() }.label == want)
        #expect(DelayedProgress(isBusy: true).label == want)
        #expect(SpinnerSlot(shown: true, label: "Reading").label == "Reading")
    }
    #endif

    // MARK: Language

    @Test func theLanguageFollowsThePreferenceListAndFallsBackToEnglish() {
        #expect(GlamorText.code(preferences: ["id-ID"]) == "id")
        #expect(GlamorText.code(preferences: ["fr-FR", "id"]) == "id", "the first language the catalog has wins")
        #expect(GlamorText.code(preferences: ["en-US", "id"]) == "en")
        #expect(GlamorText.code(preferences: ["fr", "de"]) == "en")
        #expect(GlamorText.code(preferences: []) == "en")
        #expect(GlamorText.string(.copy, preferences: ["id-ID"]) == "Salin")
        #expect(GlamorText.string(.copy, preferences: ["zh-Hans"]) == "Copy")
    }

    /// The host app's languages come first, so Glamor's words match the app's own: an English-only app on a Mac set to
    /// Indonesian says "Copy", not "Salin", beside its English.
    @Test func theHostAppsLanguageWinsOverThePersonsList() {
        #expect(GlamorText.code(host: ["en"], preferences: ["id-ID", "en"]) == "en", "an English-only host stays English")
        #expect(GlamorText.string(.copy, host: ["en"], preferences: ["id-ID"]) == "Copy")
        #expect(GlamorText.code(host: ["en-GB"], preferences: ["id"]) == "en")
        #expect(GlamorText.code(host: ["id", "en"], preferences: ["id-ID", "en"]) == "id", "a host that ships Indonesian")
        #expect(GlamorText.string(.copy, host: ["id"], preferences: ["en"]) == "Salin")
    }

    @Test func aHostWithNoLanguageTheCatalogHasLeavesItToThePersonsList() {
        #expect(GlamorText.code(host: [], preferences: ["id-ID"]) == "id", "a bare tool with no languages of its own")
        #expect(GlamorText.code(host: ["Base"], preferences: ["id-ID"]) == "id")
        #expect(GlamorText.code(host: ["fr"], preferences: ["id", "en"]) == "id", "a French-only host: the person's list")
        #expect(GlamorText.code(host: ["fr"], preferences: ["de"]) == "en", "then English")
    }

    @Test func numbersAreWrittenForTheResolvedLanguage() {
        // A bare .lproj bundle has no Info.plist; the locale comes from the resolved code, not from the bundle.
        #expect(GlamorText.string(.percent, language: "id", 1_000) == "1.000 persen")
        #expect(GlamorText.string(.percent, language: "en", 1_000) == "1,000 percent")
    }

    // MARK: Words

    @Test func theLibraryWordsReadRightInBothLanguages() {
        #expect(GlamorText.string(.copy, language: "en") == "Copy")
        #expect(GlamorText.string(.copied, language: "id") == "Disalin")
        #expect(GlamorText.string(.percent, language: "en", 60) == "60 percent")
        #expect(GlamorText.string(.percent, language: "id", 60) == "60 persen")
        #expect(GlamorText.string(.moreFor, language: "id", "web-1") == "Lainnya untuk web-1")
        #expect(GlamorText.string(.splitHint, language: "id", 272) == "Tekan Kembalikan untuk mengatur ulang ke 272.")
    }

    @Test func theThemeSwitchPresetsAreTheCatalogsWords() {
        #expect(ThemeSwitchWords.english == ThemeSwitchWords(toDark: "Switch to dark theme", toLight: "Switch to light theme"))
        #expect(ThemeSwitchWords.indonesian == ThemeSwitchWords(toDark: "Ganti ke tema gelap", toLight: "Ganti ke tema terang"))
        #expect([ThemeSwitchWords.english, .indonesian].contains(ThemeSwitchWords.current))
    }

    #if os(macOS)
    @Test func aDividerSpeaksItsSizeInBothLanguages() {
        let range: ClosedRange<CGFloat> = 224...400
        #expect(SplitSize.spoken(272, in: range, language: "en") == "272, from 224 to 400")
        #expect(SplitSize.spoken(272, in: range, language: "id") == "272, dari 224 sampai 400")
        #expect(SplitSize.spoken(900, in: 320...CGFloat.infinity, language: "en") == "900, at least 320")
        #expect(SplitSize.spoken(900, in: 320...CGFloat.infinity, language: "id") == "900, minimal 320")
        #expect(SplitSize.tip(288, in: range, language: "id") == "288")
        #expect(SplitSize.tip(224, in: range, language: "en") == "224 · smallest")
        #expect(SplitSize.tip(400, in: range, language: "id") == "400 · terbesar")
    }
    #endif

    // MARK: No user-facing word outside the catalog

    private func sourceFiles(_ folder: String) throws -> [URL] {
        let dir = Self.root.appendingPathComponent(folder)
        let all = FileManager.default.enumerator(at: dir, includingPropertiesForKeys: nil)?.compactMap { $0 as? URL } ?? []
        return all.filter { $0.pathExtension == "swift" && !$0.path.contains("/Generated/") }
    }

    /// A line without its `//` comment (a `//` inside a string, as in a URL, stays).
    private func code(_ line: String) -> String {
        var quotes = 0
        var previous: Character = " "
        for (i, c) in line.enumerated() {
            if c == "\"" { quotes += 1 }
            if c == "/", previous == "/", quotes % 2 == 0 { return String(line.prefix(i - 1)) }
            previous = c
        }
        return line
    }

    /// Where a literal with letters reaches the person: a view or control's text, a tooltip, a VoiceOver name,
    /// hint, value or action, an announcement, or the default of a String argument. `Text(verbatim:)` is data.
    private static let sinks: [NSRegularExpression] = [
        #"\b(?:Text|Button|Label|TextField|SecureField|Toggle|Picker|Menu|Section|Link|ProgressView|Announcement)\(\s*"[^"]*[A-Za-z]"#,
        #"\.(?:help|accessibilityLabel|accessibilityHint|accessibilityValue|navigationTitle|navigationSubtitle|accessibilityInputLabels)\(\s*"[^"]*[A-Za-z]"#,
        #"\.accessibilityAction\(named:\s*"[^"]*[A-Za-z]"#,
        #"\bString\s*=\s*"[^"]*[A-Za-z]"#,
        #"\b(?:title|label|placeholder|help|hint|prompt)\s*:\s*"[^"]*[A-Za-z]"#,
        #"\?\s*"[^"]*[A-Za-z]{2}[^"]*"\s*:"#,
        // A label that defaults to an empty string leaves a spinner or a control with no name for VoiceOver (GL22).
        #"\blabel\s*:\s*String\??\s*=\s*"""#,
    ].map { try! NSRegularExpression(pattern: $0) }

    private func strays(in folder: String) throws -> [String] {
        var found = [String]()
        for file in try sourceFiles(folder) {
            let lines = try String(contentsOf: file, encoding: .utf8).components(separatedBy: "\n")
            for (n, raw) in lines.enumerated() {
                // A `print` is a developer's log line and an SF Symbol name is an icon: neither is text a person reads.
                guard !raw.contains("print("), !raw.contains("systemName:") else { continue }
                let line = code(raw)
                let range = NSRange(line.startIndex..., in: line)
                if Self.sinks.contains(where: { $0.firstMatch(in: line, range: range) != nil }) {
                    found.append("\(file.lastPathComponent):\(n + 1): \(line.trimmingCharacters(in: .whitespaces))")
                }
            }
        }
        return found
    }

    @Test func noLibrarySourceSaysAWordOutsideTheCatalog() throws {
        let stray = try strays(in: "Sources/Glamor").filter { !$0.hasPrefix("GlamorText.swift") }
        #expect(stray.isEmpty, "user-facing text outside the catalog:\n\(stray.joined(separator: "\n"))")
    }

    @Test func noGallerySourceSaysAWordOutsideItsCatalog() throws {
        let stray = try strays(in: "Sources/GlamorGallery")
        #expect(stray.isEmpty, "user-facing text outside the gallery's catalog:\n\(stray.joined(separator: "\n"))")
    }

    @Test func theScanSeesAHardcodedWord() {
        // The scan itself: a literal in each kind of place is caught, data is not.
        let bad = [#"Text("Save")"#, #".help("Copy it")"#, #".accessibilityLabel(copied ? "Copied" : help)"#,
                   #"public var help: String = "Copy""#, #".accessibilityAction(named: "Put Back")"#, #"AccessibilityNotification.Announcement("Copied")"#,
                   #"public init(shown: Bool, label: String = "") {"#, #"public init(isBusy: Bool, label: String? = "") {"#]
        let good = [#"Text(verbatim: "web-1")"#, #"Text(GlamorText.string(.copy))"#, #"let key = "size.""#, #"Text(title) // "Save""#]
        func hit(_ s: String) -> Bool {
            let line = code(s)
            return Self.sinks.contains { $0.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) != nil }
        }
        for s in bad { #expect(hit(s), "missed: \(s)") }
        for s in good { #expect(!hit(s), "false alarm: \(s)") }
    }

    // MARK: Gallery catalog

    @Test func everyGalleryStringHasEnglishAndIndonesian() throws {
        checkComplete(try catalog("Sources/GlamorGallery/Resources/Localizable.xcstrings"), named: "Gallery")
    }

    @Test func theGalleryUsesExactlyItsCatalogsKeys() throws {
        let keys = Set(try catalog("Sources/GlamorGallery/Resources/Localizable.xcstrings").map(\.key))
        let text = try String(contentsOf: Self.root.appendingPathComponent("Sources/GlamorGallery/main.swift"), encoding: .utf8)
        let pattern = try NSRegularExpression(pattern: #""([a-z]+\.[A-Za-z]+)""#)
        let used = Set(pattern.matches(in: text, range: NSRange(text.startIndex..., in: text)).map { String(text[Range($0.range(at: 1), in: text)!]) })
        #expect(used.subtracting(keys).isEmpty, "the gallery asks for strings the catalog lacks: \(used.subtracting(keys).sorted())")
        #expect(keys.subtracting(used).isEmpty, "the catalog holds strings the gallery never shows: \(keys.subtracting(used).sorted())")
    }
}
