import Foundation
import Testing
import Glamor

struct DecorTests {
    @Test func everyPatternStaysFaint() {
        #expect(DecorPattern.allCases.count == 4)
        for pattern in DecorPattern.allCases {
            #expect(pattern.strongest > 0 && pattern.strongest <= 0.7)
        }
        // Only the mesh may paint broadly; the line and dot patterns stay under a quarter.
        for pattern in [DecorPattern.noise, .grid, .dots] { #expect(pattern.strongest <= 0.25) }
    }

    /// A backdrop says nothing: it is hidden from VoiceOver, takes no touches and holds no animation.
    @Test func decorIsHiddenStillAndInert() throws {
        let file = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Sources/Glamor/Decor/Decor.swift")
        let source = try String(contentsOf: file, encoding: .utf8)
        #expect(source.contains(".accessibilityHidden(true)"))
        #expect(source.contains(".allowsHitTesting(false)"))
        #expect(!source.contains("withAnimation") && !source.contains(".animation(") && !source.contains("TimelineView"))
    }
}
