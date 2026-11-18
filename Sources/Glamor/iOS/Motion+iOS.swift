#if os(iOS)
import SwiftUI

// Motion only explains a change (design/README.md › Motion, design/components/MotionSpec). The phone's views
// never write a curve or a duration: they use these, and scripts/check-motion.sh fails on a literal one
// anywhere else. The times are PhoneMotion's (tested), the same as the Mac's G.Motion.

public extension G {
    enum Motion {
        /// motion-fast (120 ms): a symbol replaced, a cover fading away. Also the Reduce Motion fade.
        public static let fast: Animation = .easeOut(duration: PhoneMotion.fast)
        /// motion-base (200 ms, no bounce): something arriving in place, the conversation moving to its newest item.
        public static let base: Animation = .spring(duration: PhoneMotion.base, bounce: 0)

        /// The animation for a token: with Reduce Motion, base becomes the motion-fast fade.
        public static func animation(_ token: PhoneMotion.Token, reduceMotion: Bool) -> Animation {
            PhoneMotion.seconds(token, reduceMotion: reduceMotion) == PhoneMotion.base ? base : fast
        }
    }
}

private struct MKAnimation<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let token: PhoneMotion.Token
    let value: V
    func body(content: Content) -> some View {
        content.animation(G.Motion.animation(token, reduceMotion: reduceMotion), value: value)
    }
}

public extension View {
    /// Animates changes of `value` with a motion token, following Reduce Motion.
    func gAnimation<V: Equatable>(_ token: PhoneMotion.Token, value: V) -> some View {
        modifier(MKAnimation(token: token, value: value))
    }

    /// A cover that hides content (the app switcher's privacy cover): it is there at once, so nothing shows
    /// through while it arrives, and fades away over motion-fast. Pair it with gAnimation(.fast, value:).
    func mkCoverTransition() -> some View {
        transition(.asymmetric(insertion: .identity, removal: .opacity))
    }
}

/// withAnimation with a motion token. Pass the view's Reduce Motion setting.
@MainActor func withGAnimation(_ token: PhoneMotion.Token, reduceMotion: Bool, _ body: () -> Void) {
    withAnimation(G.Motion.animation(token, reduceMotion: reduceMotion), body)
}
#endif
