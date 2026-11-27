import Foundation
import SwiftUI
import Testing
@testable import Glamor

/// GL36: the Pro and Soon marks. Colour is never the only sign: the word differs and so does the outline (solid or
/// dashed). VoiceOver says what the mark means ("Pro, paid feature"), in the person's language. Contrast is in
/// ContrastTests (four modes).
struct PlanMarkTests {
    private var root: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }

    private func source(_ path: String) throws -> String {
        try String(contentsOf: root.appendingPathComponent("Sources/Glamor").appendingPathComponent(path), encoding: .utf8)
    }

    @Test func theMarksSayProAndSoonInEnglishAndIndonesian() {
        #expect(PlanMark.pro.word(language: "en") == "Pro")
        #expect(PlanMark.soon.word(language: "en") == "Soon")
        #expect(PlanMark.pro.word(language: "id") == "Pro")
        #expect(PlanMark.soon.word(language: "id") == "Segera")
    }

    @Test func voiceOverSaysWhatEachMarkMeans() {
        #expect(PlanMark.pro.spoken(language: "en") == "Pro, paid feature")
        #expect(PlanMark.soon.spoken(language: "en") == "Soon, not available yet")
        #expect(PlanMark.pro.spoken(language: "id") == "Pro, fitur berbayar")
        #expect(PlanMark.soon.spoken(language: "id") == "Segera, belum tersedia")
    }

    @Test func theSpokenWordsStartWithTheWordTheEyeReads() {
        for mark in PlanMark.allCases {
            for language in GlamorText.languages {
                #expect(mark.spoken(language: language).hasPrefix(mark.word(language: language)), "\(mark) \(language)")
            }
        }
    }

    @Test func colourIsNeverTheOnlyDifference() {
        #expect(PlanMark.pro.word(language: "en") != PlanMark.soon.word(language: "en"))
        #expect(PlanMark.pro.dash.isEmpty, "Pro is a solid outline")
        #expect(PlanMark.soon.dash == [G.Space.s4, G.Space.s4], "Soon is dashed, as the page's DashedDivider")
    }

    @Test func aMarkPillShowsTheMarksWordAndNamesItsMeaning() {
        let pill = Pill(mark: .pro)
        #expect(pill.mark == .pro)
        #expect(pill.text == PlanMark.pro.word())
        #expect(Pill(mark: .soon).text == PlanMark.soon.word())
    }

    @Test func aPillMadeFromWordsAndAColourIsNotAMark() {
        let pill = Pill(text: "Running", color: G.ok)
        #expect(pill.mark == nil)
        #expect(pill.text == "Running")
    }

    @Test func bothPillsGiveAMarkOneSpokenElement() throws {
        var files = ["iOS/Surfaces+iOS.swift"]
        #if os(macOS)
        files = ["macOS/Controls.swift"]
        #endif
        for file in files {
            let text = try source(file)
            let pill = try #require(text.range(of: "public struct Pill"))
            let body = String(text[pill.lowerBound...].prefix(2600))
            #expect(body.contains(".accessibilityElement(children: .ignore)"), "\(file)")
            #expect(body.contains(".accessibilityLabel(mark.spoken()"), "\(file)")
            #expect(body.contains("PlanMarkEdge"), "\(file)")
        }
    }

    @Test func theMarkSourcesAreOneTypePerFile() throws {
        let mark = try source("Marks/PlanMark.swift")
        #expect(mark.contains("public enum PlanMark"))
        #expect(!mark.contains("struct "))
        let edge = try source("Marks/PlanMarkEdge.swift")
        #expect(edge.contains("struct PlanMarkEdge"))
        #expect(!edge.contains("enum "))
    }
}
