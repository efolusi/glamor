#if os(macOS)
import Foundation
import Testing

/// GL38 and GL37: the `sidebar-b` and `profile` scenes are gallery files, control lists in scripts/window/WindowCheck.swift
/// and run lines in scripts/check-window.sh. The window check itself is the owner's sitting; these keep the three from
/// drifting apart.
struct RailAndProfileWindowCheckTests {
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

    @Test func theGalleryListsBothScenesWithOneLineEach() throws {
        let all = try read("Sources/GlamorGallery/Scenes/GalleryScenes.swift")
        #expect(all.contains("static let all = [components, sidebarA, sidebarB, profile]"))
        let rail = try read("Sources/GlamorGallery/Scenes/SidebarBScene.swift")
        #expect(rail.contains(#"GalleryScene(name: "sidebar-b", size: CGSize(width: G.Width.sidebar, height: G.Height.windowMin)"#))
        let profile = try read("Sources/GlamorGallery/Scenes/ProfileScene.swift")
        #expect(profile.contains(#"GalleryScene(name: "profile", size: CGSize(width: G.Width.sidebar"#))
    }

    /// The rail's 72 and the column's 184 fill the sidebar's 256: the window is as wide as the sidebar.
    @Test func theRailSceneUsesTheRailTheColumnAndTheAvatarFooter() throws {
        let rail = try read("Sources/GlamorGallery/Scenes/SidebarBScene.swift")
        #expect(rail.contains("SidebarRail(registry: registry, area: $area)"))
        #expect(rail.contains("SidebarColumn(section.title)"))
        #expect(rail.contains("ProfileDemo.card(.avatar)"))
        #expect(!rail.contains("@SceneStorage"), "a bare NSHostingView has no scene")
        #expect(rail.contains(#"activated("area \(area)")"#), "an area change is an event the window check reads")
    }

    @Test func theProfileSceneDrawsTheRowStyleWithItsMenu() throws {
        let scene = try read("Sources/GlamorGallery/Scenes/ProfileScene.swift")
        #expect(scene.contains("ProfileDemo.card(.row)"))
        let demo = try read("Sources/GlamorGallery/Scenes/ProfileDemo.swift")
        #expect(demo.contains("ProfileCard(name: name, detail: detail, style: style) { ProfileDemoMenu() }"))
    }

    @Test func theWindowCheckListsTheRailThenTheAvatarThenTheColumnInReadingOrder() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains(#""sidebar-b": SceneSpec(name: "sidebar-b""#))
        #expect(check.contains("pixels: sidebarBPixels"))
        #expect(check.contains("afterActions: sidebarBAfterActions"))
        #expect(check.contains("keys: sidebarBKeys"))
        let start = try #require(check.range(of: "let sidebarBControls"))
        let end = try #require(check.range(of: #""components": SceneSpec"#))
        let list = String(check[start.upperBound..<end.lowerBound])
        let rail = try #require(list.range(of: "sidebarBRailNames"))
        let avatar = try #require(list.range(of: "profileSpoken"))
        let column = try #require(list.range(of: "Search"))
        #expect(rail.lowerBound < avatar.lowerBound && avatar.lowerBound < column.lowerBound, "Tab order: rail, its footer, then the column")
    }

    @Test func theRailNamesInTheCheckAreTheDemosAreasAndThePressedAreasDoNotFireEvents() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        let names = try #require(try matches(#"let sidebarBRailNames = \[([^\]]*)\]"#, in: check).first)
        #expect(names == #""Home", "Targets", "Across", "Own", "About", "Settings""#)
        let demo = try read("Sources/GlamorGallery/Scenes/SidebarDemo.swift")
        for short in ["Targets", "Across", "Own", "About"] { #expect(demo.contains(#""\#(short)""#)) }
        // A rail item has no pressEvent in the list: the area presses run last, so the column rows are still there for the row presses.
        #expect(check.contains("selected: $0 == sidebarBStartArea, pressEvent: nil"))
    }

    @Test func theWindowCheckHasAListForTheProfileSceneWithPixelsStringsAndKeys() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains(#""profile": SceneSpec(name: "profile""#))
        #expect(check.contains("pixels: profilePixels"))
        #expect(check.contains("afterActions: profileAfterActions"))
        #expect(check.contains("keys: profileKeys"))
        #expect(check.contains(#"let profileName = "Alex Morgan""#))
        let demo = try read("Sources/GlamorGallery/Scenes/ProfileDemo.swift")
        #expect(demo.contains(#"static let name = "Alex Morgan""#))
    }

    @Test func thePopoverIsSearchedForInTheWholeApplicationNotOnlyTheWindow() throws {
        let check = try read("scripts/window/WindowCheck.swift")
        #expect(check.contains("descendants(app).filter { text($0, \"AXRole\") == \"AXPopover\" }"))
    }

    @Test func theScriptRunsTheRailSceneInFourPixelModesAndInStringsAndKeys() throws {
        let script = try read("scripts/check-window.sh")
        let start = try #require(script.range(of: "scene sidebar-b"))
        let lines = script[start.upperBound...].split(separator: "\n").prefix { !$0.hasPrefix("scene ") && !$0.hasPrefix("echo") }
        let runs = lines.filter { $0.hasPrefix("run ") }
        #expect(runs.count == 6)
        #expect(runs.filter { $0.contains(" pixels ") }.count == 4)
        #expect(runs.filter { $0.contains("--increase-contrast") }.count == 2)
        #expect(runs.contains { $0.contains(" strings ") } && runs.contains { $0.contains(" keys ") })
    }

    @Test func theScriptRunsTheProfileSceneInFourPixelModesAndInStringsAndKeys() throws {
        let script = try read("scripts/check-window.sh")
        let start = try #require(script.range(of: "scene profile"))
        let lines = script[start.upperBound...].split(separator: "\n").prefix { !$0.hasPrefix("scene ") && !$0.hasPrefix("echo") }
        let runs = lines.filter { $0.hasPrefix("run ") }
        #expect(runs.count == 6)
        #expect(runs.filter { $0.contains(" pixels ") }.count == 4)
        #expect(runs.filter { $0.contains("--increase-contrast") }.count == 2)
        #expect(runs.contains { $0.contains(" strings ") } && runs.contains { $0.contains(" keys ") })
    }

    @Test func everyDemoWordHasEnglishAndIndonesianInTheGalleryCatalog() throws {
        let data = try Data(contentsOf: Self.root.appendingPathComponent("Sources/GlamorGallery/Resources/Localizable.xcstrings"))
        let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        let strings = try #require(json["strings"] as? [String: [String: Any]])
        for key in ["profile.detail", "profile.appearance", "profile.upgrade", "profile.settings"] {
            let loc = try #require(strings[key]?["localizations"] as? [String: Any], "\(key) is not in the gallery catalog")
            #expect(Set(loc.keys) == ["en", "id"])
        }
    }
}
#endif
