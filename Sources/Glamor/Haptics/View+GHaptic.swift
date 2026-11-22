import SwiftUI

public extension View {
    /// Plays a haptic each time `trigger` changes, on iPhone. The system leaves it out when the person
    /// turned System Haptics off, and with Reduce Motion `base` softens to `fast` (see `GHaptic.resolved`).
    /// On every other platform it does nothing.
    func gHaptic<T: Equatable>(_ haptic: GHaptic, trigger: T) -> some View {
        #if os(iOS)
        modifier(GHapticModifier(haptic: haptic, trigger: trigger))
        #else
        self
        #endif
    }
}

#if os(iOS)
private struct GHapticModifier<T: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let haptic: GHaptic
    let trigger: T

    func body(content: Content) -> some View {
        content.sensoryFeedback(trigger: trigger) { _, _ in
            switch haptic.resolved(reduceMotion: reduceMotion) {
            case .selection: .selection
            case .fast: .impact(weight: .light)
            case .base: .impact(weight: .medium)
            case .success: .success
            case .warning: .warning
            case .error: .error
            }
        }
    }
}

public extension GHaptic {
    /// The haptic that goes with a motion token: the same size as the change it accompanies.
    /// iOS only: `PhoneMotion` does not exist on the Mac.
    init(_ token: PhoneMotion.Token) {
        self = token == .base ? .base : .fast
    }
}
#endif
