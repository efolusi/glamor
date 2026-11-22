import Foundation

/// Haptic tokens. A touch answers with the same two sizes as the motion scale: `fast` is the small tap that
/// goes with a motion-fast change, `base` the firmer one that goes with motion-base. `selection`, `success`,
/// `warning` and `error` are the system's own patterns. Only the iPhone plays them (see `View.gHaptic`);
/// every other platform ignores them.
public enum GHaptic: CaseIterable, Sendable {
    case selection, fast, base, success, warning, error

    /// What plays for this token. With Reduce Motion the firm `base` tap becomes the small `fast` one, as
    /// motion-base becomes the motion-fast fade; the system patterns for a result and `selection` stay,
    /// because they report an outcome and do not move anything.
    public func resolved(reduceMotion: Bool) -> GHaptic {
        self == .base && reduceMotion ? .fast : self
    }
}
