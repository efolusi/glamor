import Foundation

/// The one list of places. The sidebar, the rail, the Go menu, ⌘K, the iPad sidebar and the phone tabs all read it, so
/// they cannot disagree about what exists or in which order. The app owns the data; Glamor owns the type, the search
/// and the checks (`problems()`, `unplaced(_:)`).
public struct PlaceRegistry: Sendable {
    public let home: Place
    public let sections: [PlaceSection]
    public let settings: Place
    /// Home, every section's places, then Settings: the one order for every caller and for the shortcut numbers.
    public let places: [Place]

    public init(home: Place, sections: [PlaceSection], settings: Place) {
        self.home = home
        self.sections = sections
        self.settings = settings
        places = [home] + sections.flatMap(\.places) + [settings]
    }

    public func place(id: Place.ID) -> Place? {
        places.first { $0.id == id }
    }

    /// The section that holds the place. Home and Settings belong to none.
    public func section(containing id: Place.ID) -> PlaceSection? {
        sections.first { $0.places.contains { $0.id == id } }
    }

    /// The feature ids from `featureIDs` that no place holds, in the order given. An app lists every feature it ships
    /// and fails its test when this is not empty: a feature with no entry has no way in.
    public func unplaced(_ featureIDs: [String]) -> [String] {
        let held = Set(places.flatMap(\.features).map(\.id))
        return featureIDs.filter { !held.contains($0) }
    }
}
