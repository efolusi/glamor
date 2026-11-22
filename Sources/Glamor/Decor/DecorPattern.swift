import Foundation

/// The four backdrops of `Decor`, the same names as Meridian's `Decor`. The strengths are the most a
/// pattern ever paints, as a share of its colour: body text keeps 4.5:1 over the strongest point.
public enum DecorPattern: CaseIterable, Sendable {
    /// A soft gradient from the accent colours.
    case mesh
    /// Fine grain.
    case noise
    /// Hairlines in a square grid.
    case grid
    /// A grid of dots.
    case dots

    /// The most of its colour the pattern paints at any point.
    public var strongest: Double {
        switch self {
        case .mesh: 0.7
        case .noise: 0.12
        case .grid: 0.16
        case .dots: 0.22
        }
    }
}
