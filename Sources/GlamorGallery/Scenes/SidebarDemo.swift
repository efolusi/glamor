#if os(macOS)
import Glamor

/// The data the sidebar scenes draw: the 21 places of the komando apps in four sections, with Home and Settings.
/// A place's CLI word is data and is not translated; the section titles, Home and Settings are words, from the
/// gallery's catalog. Glamor holds none of these: the registry type is the library's, the data is this demo's.
enum SidebarDemo {
    /// The row that is chosen when the scene opens.
    static let start = "host"

    static var registry: PlaceRegistry {
        PlaceRegistry(
            home: Place(id: "home", title: Words.text("sidebar.home"), symbol: "house"),
            sections: [
                section("targets", Words.text("sidebar.targets"), "Targets", "scope", [
                    ("Host", "desktopcomputer"), ("Database", "cylinder.split.1x2"), ("Cache", "bolt"), ("Queue", "tray.2"),
                    ("Storage", "externaldrive"), ("Cluster", "square.stack.3d.up"), ("Registry", "shippingbox"),
                    ("VPN", "network.badge.shield.half.filled"), ("Cloud", "cloud"),
                ]),
                section("across", Words.text("sidebar.across"), "Across", "square.on.square", [
                    ("Copy", "doc.on.doc"), ("Tunnel", "arrow.left.arrow.right"), ("Sessions", "terminal"),
                ]),
                section("own", Words.text("sidebar.own"), "Own", "person.2", [
                    ("Snippet", "chevron.left.forwardslash.chevron.right"), ("Credential", "key"), ("Group", "square.grid.2x2"),
                    ("Policy", "shield"),
                ]),
                section("about", Words.text("sidebar.about"), "About", "info.circle.fill", [
                    ("Audit", "doc.text.magnifyingglass"), ("Doctor", "stethoscope"), ("Agent", "person.crop.circle"),
                ]),
            ],
            settings: Place(id: "settings", title: Words.text("sidebar.settings"), symbol: "gearshape")
        )
    }

    /// The two rows that show a count: running transfers, and findings to review.
    static var counts: [Place.ID: SidebarCount] {
        ["copy": SidebarCount(2, spoken: Words.text("count.transfers", "2")),
         "doctor": SidebarCount(3, spoken: Words.text("count.findings", "3"))]
    }

    private static func section(_ id: String, _ title: String, _ shortTitle: String, _ symbol: String,
                                _ places: [(word: String, symbol: String)]) -> PlaceSection {
        PlaceSection(id: id, title: title, shortTitle: shortTitle, symbol: symbol,
                     places: places.map { Place(id: $0.word.lowercased(), title: $0.word, symbol: $0.symbol) })
    }
}
#endif
