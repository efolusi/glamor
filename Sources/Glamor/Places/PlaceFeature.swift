import Foundation

/// Something a person can do inside a place. ⌘K shows it after the place: "Notes › Pin a note".
public struct PlaceFeature: Identifiable, Hashable, Sendable {
    /// A stable key the app owns, for example "notes.pin". Unique across the whole registry.
    public let id: String
    /// What ⌘K shows, in the person's language.
    public let title: String
    /// Extra words ⌘K matches besides the title.
    public let keywords: [String]

    public init(id: String, title: String, keywords: [String] = []) {
        self.id = id
        self.title = title
        self.keywords = keywords
    }
}
