import Foundation

public extension PlaceRegistry {
    /// What is wrong with the data, one sentence per fault, empty when it is sound. Developer text, not shown to a person.
    /// Place ids and section ids share one set, because the rail's selected area holds either; feature ids are their own set.
    func problems() -> [String] {
        var found = [String]()

        found += repeated(places.map(\.id) + sections.map(\.id)).map { "id \"\($0)\" is used by more than one place or section" }
        found += repeated(places.flatMap(\.features).map(\.id)).map { "feature id \"\($0)\" is used more than once" }

        for place in places {
            let name = place.id.isBlank ? place.title : place.id
            if place.id.isBlank { found.append("place \"\(place.title)\" has an empty id") }
            if place.title.isBlank { found.append("place \"\(name)\" has an empty title") }
            if place.symbol.isBlank { found.append("place \"\(name)\" has an empty symbol") }
            for feature in place.features {
                if feature.id.isBlank { found.append("a feature of place \"\(name)\" has an empty id") }
                if feature.title.isBlank { found.append("feature \"\(feature.id)\" of place \"\(name)\" has an empty title") }
            }
        }
        for section in sections {
            if section.id.isBlank { found.append("section \"\(section.title)\" has an empty id") }
            if section.title.isBlank { found.append("section \"\(section.id)\" has an empty title") }
            if section.shortTitle.isBlank { found.append("section \"\(section.id)\" has an empty short title") }
            if section.symbol.isBlank { found.append("section \"\(section.id)\" has an empty symbol") }
            if section.places.isEmpty { found.append("section \"\(section.id)\" has no places") }
        }
        return found
    }

    /// Each non-empty value that appears more than once, once, in first-seen order.
    private func repeated(_ values: [String]) -> [String] {
        var seen = Set<String>()
        var again = [String]()
        for value in values where !value.isBlank {
            if !seen.insert(value).inserted, !again.contains(value) { again.append(value) }
        }
        return again
    }
}

private extension String {
    var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}
