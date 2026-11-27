import Foundation

/// One titled block of places. The sidebar draws it as a section; the rail draws it as an area.
public struct PlaceSection: Identifiable, Hashable, Sendable {
    /// A stable key the app owns. The rail's selected area holds this id, so it never equals a place id.
    public let id: String
    /// The title the sidebar shows.
    public let title: String
    /// The shorter word under the rail's glyph.
    public let shortTitle: String
    /// The rail's SF Symbol name.
    public let symbol: String
    public let places: [Place]

    public init(id: String, title: String, shortTitle: String, symbol: String, places: [Place]) {
        self.id = id
        self.title = title
        self.shortTitle = shortTitle
        self.symbol = symbol
        self.places = places
    }
}
