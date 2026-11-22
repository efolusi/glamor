import Foundation

/// Which surface to draw: the system's glass, or the solid one. Glass needs macOS 26 or iOS 26. Below that, and
/// whenever the person turns on Reduce Transparency or Increase Contrast, the solid surface is drawn.
public enum GlassPath: Equatable, Sendable {
    case glass, solid

    public static func choose(reduceTransparency: Bool, increasedContrast: Bool, systemHasGlass: Bool) -> GlassPath {
        systemHasGlass && !reduceTransparency && !increasedContrast ? .glass : .solid
    }

    /// True on macOS 26 and iOS 26 and up. Every glass call sits behind the same `#available` check.
    public static var systemHasGlass: Bool {
        if #available(iOS 26, macOS 26, *) { true } else { false }
    }
}
