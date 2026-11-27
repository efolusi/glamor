import Foundation

/// One sidebar row, with the features inside its page. The app's own words go in `title`; Glamor adds none.
public struct Place: Identifiable, Hashable, Sendable {
    /// A stable key the app owns, for example "notes". Unique across places and sections.
    public let id: String
    /// The word the row shows.
    public let title: String
    /// An SF Symbol name.
    public let symbol: String
    public let features: [PlaceFeature]

    public init(id: String, title: String, symbol: String, features: [PlaceFeature] = []) {
        self.id = id
        self.title = title
        self.symbol = symbol
        self.features = features
    }
}
