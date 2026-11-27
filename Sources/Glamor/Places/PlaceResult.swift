import Foundation

/// One ⌘K hit: a place, or a feature inside it.
public struct PlaceResult: Identifiable, Hashable, Sendable {
    public let place: Place
    /// nil: the hit is the place itself.
    public let feature: PlaceFeature?

    public var id: String { feature.map { "\(place.id)/\($0.id)" } ?? place.id }
}
