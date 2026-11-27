#if os(macOS)
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
}
#endif
