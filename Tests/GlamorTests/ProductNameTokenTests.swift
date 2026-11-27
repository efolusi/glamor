import Foundation
import Testing

/// GL42: komando's page words (a Hosts name column, the Jobs log, the Files panes, the Port Forwarding columns)
/// are the app's sizes, not Glamor's. The names below were removed from `G` together; a view or a token file
/// that brings one back must change this test with the reason.
struct ProductNameTokenTests {
    /// `G.Width` and `G.Resize` names that carried a komando page word.
    static let widthNames = ["hostName", "connName", "secretName", "jobLog", "cacheKeys", "forwardName", "forwardKind", "updateKind"]
    static let resizeNames = ["recipes", "jobs", "audit", "filesPane", "filesTransfers", "querySplit", "cacheSplit", "terminalSplit"]
    /// The `tokens.json` entry that documented two of the width names.
    static let tokenEntries = ["forward-columns"]

    private var root: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }

    private func source(_ path: String) throws -> String {
        try String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
    }

    /// A declaration is `static let <name>`; the word alone also turns up in comments, so match the declaration.
    private func declares(_ source: String, _ name: String) -> Bool {
        source.range(of: "static let \(name)\\b", options: .regularExpression) != nil
    }

    @Test func theMacTokensDeclareNoProductPageWidth() throws {
        let tokens = try source("Sources/Glamor/macOS/Tokens.swift")
        for name in Self.widthNames + Self.resizeNames {
            #expect(!declares(tokens, name), "G still declares \(name)")
        }
    }

    @Test func theIOSTokensDeclareNoProductPageWidth() throws {
        let tokens = try source("Sources/Glamor/iOS/Tokens+iOS.swift")
        for name in Self.widthNames + Self.resizeNames {
            #expect(!declares(tokens, name), "the iOS G declares \(name)")
        }
    }

    @Test func theResizeAreasHoldOnlyTheAreasGlamorDraws() throws {
        let tokens = try source("Sources/Glamor/macOS/Tokens.swift")
        let list = try #require(tokens.range(of: "public static let areas = ["))
        let line = tokens[list.upperBound...].prefix { $0 != "]" }
        let names = line.split { !$0.isLetter }.map(String.init)
        #expect(names == ["sidebar", "agent"], "G.Resize.areas lists \(names)")
    }

    @Test func tokensJsonKeepsNoEntryNamingAProductWidth() throws {
        let json = try source("tokens.json")
        for entry in Self.tokenEntries {
            #expect(!json.contains("\"name\": \"\(entry)\""), "tokens.json still has \(entry)")
        }
        for name in Self.widthNames + Self.resizeNames {
            #expect(!json.contains("G.Width.\(name)") && !json.contains("G.Resize.\(name)"), "tokens.json still names \(name)")
        }
    }
}
