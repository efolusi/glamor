import AppKit
import SwiftUI

// Motion only explains a change: what changed, where it went, or that it is still working
// (design/README.md › Motion, design/components/MotionSpec). Views never write a curve or a duration:
// they use these tokens, and scripts/check-motion.sh fails on a literal one anywhere else.

extension K {
    enum Motion {
        /// motion-fast: a symbol replaced, the copied check, the drop ring. Also the Reduce Motion fade.
        static let fast: Animation = .easeOut(duration: 0.12)
        /// motion-base: something arriving or leaving in place (a notice, a banner, an approval card).
        static let base: Animation = .spring(duration: 0.2, bounce: 0)
        /// motion-slow: a panel (the agent drawer, the transfer queue folding). Nothing is longer.
        static let slow: Animation = .spring(duration: 0.25, bounce: 0)
        /// motion-progress: a bar moving to its new value, so it never jumps.
        static let progress: Animation = .linear(duration: 0.25)
        /// motion-shift: how far an arriving thing travels (K.Space.s8).
        static let shift: CGFloat = K.Space.s8

        /// delay-spinner: a spinner or skeleton waits this long, so fast work never flashes one.
        static let spinnerDelay: Duration = .milliseconds(300)
        /// hold-spinner: once shown, the shortest time it stays.
        static let spinnerHold: Duration = .milliseconds(500)
        /// hold-confirm: how long the copied check stays.
        static let confirmHold: Duration = .milliseconds(1500)
        /// hold-notice: how long a success notice stays.
        static let noticeHold: Duration = .seconds(8)
        /// guard-click: a card that arrives on its own ignores clicks this long. Never the keyboard.
        static let clickGuard: Duration = .milliseconds(300)

        /// Debug snapshots draw every K.Motion animation off, so renders are the same every time.
        static let isOff = ProcessInfo.processInfo.environment["KOMANDO_APP_SNAPSHOT"] != nil

        /// Reduce Motion from the system, for code that has no view environment (withKAnimation).
        @MainActor static var systemReducesMotion: Bool { NSWorkspace.shared.accessibilityDisplayShouldReduceMotion }
    }
}

/// The four kinds of motion. Each knows its Reduce Motion fallback, so a view never reads the setting.
enum MotionToken: Sendable {
    case fast, base, slow, progress

    /// The animation to run, or nil for none. With Reduce Motion, base and slow become the motion-fast
    /// fade (their transitions drop the travel, see `kTransition`), and a progress bar jumps.
    func animation(reduceMotion: Bool) -> Animation? {
        if K.Motion.isOff { return nil }
        switch self {
        case .fast: return K.Motion.fast
        case .base: return reduceMotion ? K.Motion.fast : K.Motion.base
        case .slow: return reduceMotion ? K.Motion.fast : K.Motion.slow
        case .progress: return reduceMotion ? nil : K.Motion.progress
        }
    }
}

/// How something arrives and leaves.
enum MotionTransition: Sendable {
    /// Fades in moving motion-shift (8) from above (a notice) or below (a card).
    case appear(from: VerticalEdge)
    /// Fades only: the lock cover, a drop ring, a label.
    case fade
    /// Slides in from the trailing edge: the agent drawer.
    case drawer

    /// With Reduce Motion nothing travels: every transition is a fade.
    func transition(reduceMotion: Bool) -> AnyTransition {
        if reduceMotion { return .opacity }
        switch self {
        case .appear(let edge): return .opacity.combined(with: .offset(y: edge == .top ? -K.Motion.shift : K.Motion.shift))
        case .fade: return .opacity
        case .drawer: return .move(edge: .trailing).combined(with: .opacity)
        }
    }
}

private struct KAnimation<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let token: MotionToken
    let value: V
    func body(content: Content) -> some View {
        content.animation(token.animation(reduceMotion: reduceMotion), value: value)
    }
}

private struct KTransition: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let kind: MotionTransition
    func body(content: Content) -> some View {
        content.transition(kind.transition(reduceMotion: reduceMotion))
    }
}

/// guard-click: for a card that arrives on its own (the agent's approval card). Clicks and taps wait
/// 300 ms after it appears, so a click meant for the old layout can't press Allow Once. Nothing is
/// dimmed, and the keyboard (Return, Esc, Tab) is never blocked.
private struct ClickGuard: ViewModifier {
    @State private var ready = false
    func body(content: Content) -> some View {
        content
            .allowsHitTesting(ready)
            .task {
                if !K.Motion.isOff { try? await Task.sleep(for: K.Motion.clickGuard) }
                ready = true
            }
    }
}

extension View {
    /// Animates changes of `value` with a motion token, following Reduce Motion.
    func kAnimation<V: Equatable>(_ token: MotionToken, value: V) -> some View {
        modifier(KAnimation(token: token, value: value))
    }

    /// How this view arrives and leaves, following Reduce Motion. Pair it with kAnimation or withKAnimation.
    func kTransition(_ kind: MotionTransition) -> some View {
        modifier(KTransition(kind: kind))
    }

    /// guard-click: ignores clicks and taps for the first 300 ms after the view appears.
    func clickGuard() -> some View { modifier(ClickGuard()) }
}

/// withAnimation with a motion token, following the system's Reduce Motion.
@MainActor @discardableResult
func withKAnimation<Result>(_ token: MotionToken, _ body: () throws -> Result) rethrows -> Result {
    try withAnimation(token.animation(reduceMotion: K.Motion.systemReducesMotion), body)
}
