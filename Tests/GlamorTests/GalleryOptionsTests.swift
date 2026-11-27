#if os(macOS)
import Foundation
import Testing
@testable import GlamorGallery

/// The gallery used to run `components` for a `--scene=name` and for a `--scene` with no word after it, so a
/// mistyped launch looked like a pass. Every argument that starts with `--scene` now names a scene or is refused.
struct GalleryOptionsTests {
    private let binary = "GlamorGallery"

    @Test func noSceneArgumentIsAbsent() {
        #expect(SceneArgument.parse([binary]) == .absent)
        #expect(SceneArgument.parse([binary, "--appearance", "dark"]) == .absent)
    }

    @Test func aSceneNameIsTheNextWord() {
        #expect(SceneArgument.parse([binary, "--scene", "components"]) == .name("components"))
        #expect(SceneArgument.parse([binary, "--appearance", "dark", "--scene", "components"]) == .name("components"))
    }

    @Test func aSceneNameCanFollowAnEqualsSign() {
        #expect(SceneArgument.parse([binary, "--scene=components"]) == .name("components"))
    }

    @Test func aSceneFlagWithNoWordIsMalformed() {
        #expect(SceneArgument.parse([binary, "--scene"]) == .malformed("--scene"))
        #expect(SceneArgument.parse([binary, "--scene="]) == .malformed("--scene="))
    }

    @Test func aSceneFlagFollowedByAnotherFlagIsMalformed() {
        #expect(SceneArgument.parse([binary, "--scene", "--appearance", "dark"]) == .malformed("--scene"))
    }

    @Test func anotherSpellingThatStartsWithSceneIsMalformed() {
        #expect(SceneArgument.parse([binary, "--scenes", "components"]) == .malformed("--scenes"))
    }

    // MARK: Scenes and their window-check lists

    @Test func theMarksSceneIsOneLineInAll() {
        #expect(GalleryScenes.all.map(\.name) == ["components", "marks"])
        #expect(GalleryScenes.named("marks") != nil)
        #expect(GalleryScenes.fallback.name == "components", "no --scene still shows the components scene")
    }

    /// A scene the gallery can show with no list in the window check would stop `check-window.sh` with "unknown scene".
    @Test func everyGallerySceneHasAListInTheWindowCheck() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let check = try String(contentsOf: root.appendingPathComponent("scripts/window/WindowCheck.swift"), encoding: .utf8)
        for scene in GalleryScenes.all {
            #expect(check.contains("\"\(scene.name)\": SceneSpec(name: \"\(scene.name)\""), "\(scene.name) has no SceneSpec in WindowCheck.swift")
        }
    }
}
#endif
