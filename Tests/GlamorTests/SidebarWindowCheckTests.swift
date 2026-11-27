#if os(macOS)
import Foundation
import Testing

/// GL40: the `sidebar-a` scene is a gallery file, a control list in scripts/window/WindowCheck.swift and run lines in
/// scripts/check-window.sh. The window check itself is the owner's sitting; these keep the three from drifting apart.
struct SidebarWindowCheckTests {
    private static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

    private func read(_ path: String) throws -> String {
        try String(contentsOf: Self.root.appendingPathComponent(path), encoding: .utf8)
    }

    private func matches(_ pattern: String, in text: String) throws -> [String] {
        let expression = try NSRegularExpression(pattern: pattern)
        return expression.matches(in: text, range: NSRange(text.startIndex..., in: text))
            .map { String(text[Range($0.range(at: 1), in: text)!]) }
    }

    @Test func theGalleryListsTheSceneAtTheSizeOfTheSmallestMainWindowSidebar() throws {
        let all = try read("Sources/GlamorGallery/Scenes/GalleryScenes.swift")
        #expect(all.contains("static let all = [components, sidebarA"), "one line in GalleryScenes.all")
        let scene = try read("Sources/GlamorGallery/Scenes/SidebarAScene.swift")
        #expect(scene.contains(#"GalleryScene(name: "sidebar-a", size: CGSize(width: G.Width.sidebar, height: G.Height.windowMin)"#))
    }

    /// `SceneStorage` has no scene in a bare `NSHostingView`: the scene holds its sections in `@State`.
    @Test func theSceneKeepsItsSectionsInStateAndNotInSceneStorage() throws {
        let scene = try read("Sources/GlamorGallery/Scenes/SidebarAScene.swift")
        #expect(scene.contains("@State private var folded"))
        #expect(!scene.contains("@SceneStorage"))
        #expect(scene.contains("isExpanded: expanded(section.id)"))
    }

    @Test func theWindowCheckListsEveryDemoPlaceInTheDemosOrder() throws {
        let demo = try read("Sources/GlamorGallery/Scenes/SidebarDemo.swift")
        let demoPlaces = try matches(#"\("([A-Za-z]+)", "[a-z0-9.]+"\)"#, in: demo)
        let check = try read("scripts/window/WindowCheck.swift")
        let start = try #require(check.range(of: "let sidebarASections"))
        let end = try #require(check.range(of: "let sidebarAStart"))
        let listed = try matches(#""([A-Za-z]+)"(?=[,\]])"#, in: String(check[start.upperBound..<end.lowerBound]))
        let sectionTitles = ["Targets", "Across types", "Komando's own", "About komando"]
        #expect(listed.filter { !sectionTitles.contains($0) } == demoPlaces)
        #expect(demoPlaces.count == 19, "21 places in the IA: 19 in the sections, Home and Settings outside them")
    }

    @Test func theWindowCheckHasAListForTheSceneWithPixelsStringsAndKeys() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains(#""sidebar-a": SceneSpec(name: "sidebar-a""#))
        #expect(check.contains("pixels: sidebarAPixels"))
        #expect(check.contains("afterActions: sidebarAAfterActions"))
        #expect(check.contains("keys: sidebarAKeys"))
        #expect(check.contains("t.scene.keys?(t)"), "keys mode runs the scene's own checks at its end")
    }

    /// A folded section that holds the chosen place: the window check reads its header value and samples the dot.
    @Test func theWindowCheckReadsTheFoldedHeaderThatHoldsTheChosenPlace() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains(#"let folded = "collapsed, \(sidebarAStart) selected""#))
        #expect(check.contains(#"check("folded-dot""#))
        let scene = try read("Sources/GlamorGallery/Scenes/SidebarAScene.swift")
        #expect(scene.contains("containsSelection: chosen != nil, selectedTitle: chosen?.title"))
    }

    @Test func theScriptRunsTheSceneInFourPixelModesAndInStringsAndKeys() throws {
        let script = try read("scripts/check-window.sh")
        let start = try #require(script.range(of: "scene sidebar-a"))
        let lines = script[start.upperBound...].split(separator: "\n").prefix { !$0.hasPrefix("echo") }
        let runs = lines.filter { $0.hasPrefix("run ") }
        #expect(runs.count == 6)
        #expect(runs.filter { $0.contains(" pixels ") }.count == 4)
        #expect(runs.contains { $0.contains(" strings ") })
        #expect(runs.contains { $0.contains(" keys ") })
        #expect(runs.filter { $0.contains("--increase-contrast") }.count == 2)
    }
}
#endif
