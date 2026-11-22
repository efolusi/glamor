import Testing
import Glamor

struct HapticTests {
    @Test func reduceMotionSoftensOnlyTheFirmTap() {
        #expect(GHaptic.base.resolved(reduceMotion: false) == .base)
        #expect(GHaptic.base.resolved(reduceMotion: true) == .fast)
        for kept in [GHaptic.selection, .fast, .success, .warning, .error] {
            #expect(kept.resolved(reduceMotion: true) == kept)
            #expect(kept.resolved(reduceMotion: false) == kept)
        }
    }

    #if os(iOS)
    @Test func aHapticMatchesItsMotionToken() {
        #expect(GHaptic(.fast) == .fast)
        #expect(GHaptic(.base) == .base)
    }
    #endif
}
