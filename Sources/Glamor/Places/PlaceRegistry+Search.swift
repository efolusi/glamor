import Foundation

public extension PlaceRegistry {
    /// The ⌘K hits for `query`: every place whose title holds each word of the query, then every feature whose title or
    /// keywords hold each word, each group in registry order. Case and accents are ignored. A blank query finds nothing:
    /// what ⌘K shows before a person types is the app's.
    func results(for query: String) -> [PlaceResult] {
        let words = query.folded.split(whereSeparator: \.isWhitespace).map(String.init)
        guard !words.isEmpty else { return [] }
        func holds(_ text: [String]) -> Bool {
            let haystack = text.joined(separator: " ").folded
            return words.allSatisfy { haystack.contains($0) }
        }

        let hitPlaces = places.filter { holds([$0.title]) }.map { PlaceResult(place: $0, feature: nil) }
        let hitFeatures = places.flatMap { place in
            place.features.filter { holds([$0.title] + $0.keywords) }.map { PlaceResult(place: place, feature: $0) }
        }
        return hitPlaces + hitFeatures
    }
}

private extension String {
    var folded: String { folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil) }
}
