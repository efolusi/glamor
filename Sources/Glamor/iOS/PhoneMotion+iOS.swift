#if os(iOS)
import Foundation

/// Motion on the phone (design/components/MotionSpec): the same times as the Mac's G.Motion, kept here so
/// they can be tested. Views use them through G.Motion (Sources/Glamor/iOS/Motion+iOS.swift), never a literal.
public enum PhoneMotion {
    public enum Token: Sendable { case fast, base }

    /// motion-fast: a symbol replaced, a cover fading away. Also the Reduce Motion fade.
    public static let fast: TimeInterval = 0.12
    /// motion-base: something arriving or leaving in place, the conversation moving to its newest item.
    public static let base: TimeInterval = 0.2
    /// delay-spinner: a spinner or skeleton waits this long, so a quick answer never flashes one.
    public static let loadingDelay: Duration = .milliseconds(300)
    /// hold-spinner: once shown, the shortest time a spinner stays.
    public static let loadingHold: Duration = .milliseconds(500)
    /// hold-confirm: how long "Copied" stays.
    public static let confirmHold: Duration = .milliseconds(1500)

    /// How long a token runs. With Reduce Motion, base becomes the motion-fast fade.
    public static func seconds(_ token: Token, reduceMotion: Bool) -> TimeInterval {
        token == .base && !reduceMotion ? base : fast
    }

    /// Whether anything may move (slide, scroll). With Reduce Motion nothing travels.
    public static func travels(_ token: Token, reduceMotion: Bool) -> Bool { token == .base && !reduceMotion }

    /// How much longer a spinner shown for `shownFor` must stay once the work is done.
    public static func holdLeft(shownFor: Duration) -> Duration { max(.zero, loadingHold - shownFor) }
}
#endif
