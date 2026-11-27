import Foundation
import Testing
@testable import Glamor

/// GL35: the place registry is one list that every caller reads (sidebar, rail, Go menu, ⌘K, iPad, phone). The data is the
/// app's; these tests use neutral words and prove the type: one order, a validity check that names each fault, search,
/// and the check that fails when a feature an app promises has no entry.
struct PlaceRegistryTests {
    private static let home = Place(id: "home", title: "Home", symbol: "house")
    private static let settings = Place(id: "settings", title: "Settings", symbol: "gearshape")

    private static let notes = Place(id: "notes", title: "Notes", symbol: "note.text", features: [
        PlaceFeature(id: "notes.pin", title: "Pin a note", keywords: ["favourite", "star"]),
        PlaceFeature(id: "notes.export", title: "Export as text"),
    ])
    private static let tags = Place(id: "tags", title: "Tags", symbol: "tag", features: [
        PlaceFeature(id: "tags.merge", title: "Merge two tags", keywords: ["combine"]),
    ])
    private static let archive = Place(id: "archive", title: "Archive", symbol: "archivebox")

    private static let work = PlaceSection(id: "work", title: "Your work", shortTitle: "Work", symbol: "folder", places: [notes, tags])
    private static let history = PlaceSection(id: "history", title: "Kept for later", shortTitle: "Later", symbol: "clock", places: [archive])

    private static let good = PlaceRegistry(home: home, sections: [work, history], settings: settings)

    // MARK: Order

    @Test func placesRunInOneOrderHomeThenEverySectionThenSettings() {
        #expect(Self.good.places.map(\.id) == ["home", "notes", "tags", "archive", "settings"])
    }

    @Test func aRegistryWithNoSectionsStillHasHomeAndSettings() {
        let bare = PlaceRegistry(home: Self.home, sections: [], settings: Self.settings)
        #expect(bare.places.map(\.id) == ["home", "settings"])
    }

    // MARK: Lookup

    @Test func aPlaceIsFoundByItsIDAndAnUnknownIDIsNil() {
        #expect(Self.good.place(id: "tags") == Self.tags)
        #expect(Self.good.place(id: "home") == Self.home)
        #expect(Self.good.place(id: "settings") == Self.settings)
        #expect(Self.good.place(id: "nowhere") == nil)
    }

    @Test func theSectionHoldingAPlaceIsFoundAndHomeAndSettingsHaveNone() {
        #expect(Self.good.section(containing: "notes") == Self.work)
        #expect(Self.good.section(containing: "archive") == Self.history)
        #expect(Self.good.section(containing: "home") == nil)
        #expect(Self.good.section(containing: "settings") == nil)
        #expect(Self.good.section(containing: "nowhere") == nil)
    }

    // MARK: Problems

    @Test func aGoodRegistryHasNoProblems() {
        #expect(Self.good.problems().isEmpty)
    }

    @Test func aRepeatedPlaceIDIsNamed() {
        let twin = Place(id: "tags", title: "Tags again", symbol: "tag")
        let bad = PlaceRegistry(home: Self.home, sections: [Self.work, PlaceSection(id: "more", title: "More", shortTitle: "More", symbol: "ellipsis", places: [twin])], settings: Self.settings)
        let found = bad.problems()
        #expect(found.count == 1)
        #expect(found.first?.contains("tags") == true)
    }

    @Test func aSettingsPlaceThatReusesHomesIDIsNamed() {
        let bad = PlaceRegistry(home: Self.home, sections: [Self.work], settings: Place(id: "home", title: "Settings", symbol: "gearshape"))
        #expect(bad.problems().contains { $0.contains("home") })
    }

    /// The rail's area binding holds the id of home, a section or settings, so those ids may not meet.
    @Test func aSectionIDThatIsAPlaceIDIsNamed() {
        let clash = PlaceSection(id: "settings", title: "Odd", shortTitle: "Odd", symbol: "questionmark", places: [Self.archive])
        let bad = PlaceRegistry(home: Self.home, sections: [clash], settings: Self.settings)
        #expect(bad.problems().contains { $0.contains("settings") })
    }

    @Test func aRepeatedSectionIDIsNamed() {
        let again = PlaceSection(id: "work", title: "Work again", shortTitle: "Again", symbol: "folder", places: [Self.archive])
        let bad = PlaceRegistry(home: Self.home, sections: [Self.work, again], settings: Self.settings)
        #expect(bad.problems().contains { $0.contains("work") })
    }

    @Test func aRepeatedFeatureIDIsNamedEvenAcrossPlaces() {
        let copy = Place(id: "archive", title: "Archive", symbol: "archivebox", features: [PlaceFeature(id: "notes.pin", title: "Pin it")])
        let bad = PlaceRegistry(home: Self.home, sections: [Self.work, PlaceSection(id: "later", title: "Later", shortTitle: "Later", symbol: "clock", places: [copy])], settings: Self.settings)
        let found = bad.problems()
        #expect(found.count == 1)
        #expect(found.first?.contains("notes.pin") == true)
    }

    @Test func anEmptyTitleIsNamedForAPlaceAFeatureAndASection() {
        let blankFeature = Place(id: "a", title: "A", symbol: "a.circle", features: [PlaceFeature(id: "a.one", title: "  ")])
        let blankPlace = Place(id: "b", title: "", symbol: "b.circle")
        let blankSection = PlaceSection(id: "c", title: "", shortTitle: "C", symbol: "c.circle", places: [Place(id: "c1", title: "C1", symbol: "c.circle")])
        let blankShort = PlaceSection(id: "d", title: "D", shortTitle: "", symbol: "d.circle", places: [Place(id: "d1", title: "D1", symbol: "d.circle")])
        let bad = PlaceRegistry(home: Self.home, sections: [
            PlaceSection(id: "ab", title: "AB", shortTitle: "AB", symbol: "ab.circle", places: [blankFeature, blankPlace]), blankSection, blankShort,
        ], settings: Self.settings)
        let found = bad.problems()
        #expect(found.contains { $0.contains("a.one") }, "the feature with a blank title: \(found)")
        #expect(found.contains { $0.contains("\"b\"") }, "the place with an empty title: \(found)")
        #expect(found.contains { $0.contains("\"c\"") }, "the section with an empty title: \(found)")
        #expect(found.contains { $0.contains("\"d\"") }, "the section with an empty short title: \(found)")
        #expect(found.count == 4)
    }

    @Test func anEmptyIDAndAnEmptySymbolAreNamed() {
        let blankID = Place(id: "", title: "Nameless", symbol: "questionmark")
        let blankSymbol = Place(id: "plain", title: "Plain", symbol: "")
        let bad = PlaceRegistry(home: Self.home, sections: [PlaceSection(id: "x", title: "X", shortTitle: "X", symbol: "x.circle", places: [blankID, blankSymbol])], settings: Self.settings)
        let found = bad.problems()
        #expect(found.contains { $0.contains("Nameless") }, "\(found)")
        #expect(found.contains { $0.contains("plain") }, "\(found)")
    }

    @Test func aSectionWithNoPlacesIsNamed() {
        let bad = PlaceRegistry(home: Self.home, sections: [Self.work, PlaceSection(id: "hollow", title: "Hollow", shortTitle: "Hollow", symbol: "circle", places: [])], settings: Self.settings)
        let found = bad.problems()
        #expect(found.count == 1)
        #expect(found.first?.contains("hollow") == true)
    }

    // MARK: Search (⌘K)

    @Test func aSearchFindsAPlaceByItsTitle() {
        let found = Self.good.results(for: "archive")
        #expect(found.map(\.place.id) == ["archive"])
        #expect(found.first?.feature == nil, "the place itself, not a feature")
    }

    @Test func aSearchFindsAFeatureByItsTitleAndReportsItsPlace() {
        let found = Self.good.results(for: "export")
        #expect(found.count == 1)
        #expect(found.first?.place.id == "notes")
        #expect(found.first?.feature?.id == "notes.export")
    }

    @Test func aSearchFindsAFeatureByAKeyword() {
        let found = Self.good.results(for: "combine")
        #expect(found.map(\.feature?.id) == ["tags.merge"])
        #expect(found.first?.place.id == "tags")
    }

    @Test func aSearchIgnoresCaseAndDiacritics() {
        #expect(Self.good.results(for: "NOTES").map(\.place.id) == ["notes"])
        #expect(Self.good.results(for: "favoürite").map(\.feature?.id) == ["notes.pin"])
        let accented = PlaceRegistry(home: Self.home, sections: [PlaceSection(id: "k", title: "K", shortTitle: "K", symbol: "k.circle", places: [Place(id: "cafe", title: "Café", symbol: "cup.and.saucer")])], settings: Self.settings)
        #expect(accented.results(for: "cafe").map(\.place.id) == ["cafe"])
        #expect(accented.results(for: "CAFÉ").map(\.place.id) == ["cafe"])
    }

    @Test func everyWordOfTheQueryMustMatch() {
        #expect(Self.good.results(for: "merge tags").map(\.feature?.id) == ["tags.merge"])
        #expect(Self.good.results(for: "merge zebra").isEmpty)
    }

    @Test func placesComeBeforeFeaturesThenRegistryOrder() {
        // "t" is in Notes, Tags, Settings (titles) and in the features Pin a note, Export as text, Merge two tags.
        let found = Self.good.results(for: "t")
        let places = found.prefix { $0.feature == nil }.map(\.place.id)
        let features = found.drop { $0.feature == nil }
        #expect(places == ["notes", "tags", "settings"])
        #expect(features.allSatisfy { $0.feature != nil }, "no place after the first feature")
        #expect(features.map(\.feature?.id) == ["notes.pin", "notes.export", "tags.merge"])
    }

    @Test func aBlankOrUnmatchedQueryFindsNothing() {
        #expect(Self.good.results(for: "").isEmpty)
        #expect(Self.good.results(for: "   ").isEmpty)
        #expect(Self.good.results(for: "zebra").isEmpty)
    }

    // MARK: A feature with no entry

    /// The "15 with no way in" fault: the app lists the feature ids it promises and the registry must hold each one.
    @Test func aPromisedFeatureWithNoEntryIsReported() {
        let promised = ["notes.pin", "notes.export", "tags.merge", "tags.rename", "archive.restore"]
        #expect(Self.good.unplaced(promised) == ["tags.rename", "archive.restore"], "in the order promised")
    }

    @Test func aCompleteRegistryLeavesNothingUnplaced() {
        #expect(Self.good.unplaced(["notes.pin", "tags.merge"]).isEmpty)
        #expect(Self.good.unplaced([]).isEmpty)
    }

    @Test func aFeatureOfHomeOrSettingsCountsAsPlaced() {
        let home = Place(id: "home", title: "Home", symbol: "house", features: [PlaceFeature(id: "home.recent", title: "Recent items")])
        let settings = Place(id: "settings", title: "Settings", symbol: "gearshape", features: [PlaceFeature(id: "settings.theme", title: "Theme")])
        let registry = PlaceRegistry(home: home, sections: [Self.work], settings: settings)
        #expect(registry.unplaced(["home.recent", "settings.theme", "nowhere.here"]) == ["nowhere.here"])
    }
}
