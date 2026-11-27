#if os(macOS)
import Foundation

/// One item of the rail: Home, a section of the registry, or Settings. A section is named by its short title
/// ("Across") and keeps its full title ("Across types") for the tooltip; Home and Settings are named by their title and
/// show no column beside the rail.
struct SidebarRailArea: Identifiable, Hashable {
    let id: String
    let name: String
    let help: String
    let symbol: String
    let hasColumn: Bool

    init(place: Place) {
        id = place.id
        name = place.title
        help = place.title
        symbol = place.symbol
        hasColumn = false
    }

    init(section: PlaceSection) {
        id = section.id
        name = section.shortTitle
        help = section.title
        symbol = section.symbol
        hasColumn = true
    }

    /// Home, every section in the registry's order, then Settings.
    static func all(in registry: PlaceRegistry) -> [SidebarRailArea] {
        [SidebarRailArea(place: registry.home)] + registry.sections.map(SidebarRailArea.init(section:)) + [SidebarRailArea(place: registry.settings)]
    }
}
#endif
