import Foundation
import Testing

/// GL39: the shape of the 44 high `SidebarItem` on iOS. An iOS test target cannot run in `swift test`, so these
/// read the source, which runs on the Mac (`SidebarItemTestsIOS` proves the behaviour in a simulator).
struct SidebarSourceTestsIOS {
    private let files = TokenSource()

    @Test func theIOSItemHasTheSameTwoInitsAsTheMac() throws {
        let ios = try files.source("iOS/SidebarItem+iOS.swift")
        #expect(ios.contains("public init(_ title: String, symbol: String, isSelected: Bool,"))
        #expect(ios.contains("public init(place: Place, selection: Binding<Place.ID>, count: SidebarCount? = nil)"))
    }

    @Test func theIOSItemIsAtLeastATouchTargetHighAndGrowsWithText() throws {
        let item = try files.source("iOS/SidebarItem+iOS.swift"), style = try files.source("iOS/SidebarItemStyle+iOS.swift")
        #expect(style.contains("static let minHeight = G.touch"))
        #expect(style.contains("minHeight: Self.minHeight"))
        #expect(!style.contains("maxHeight"), "a row that cannot grow clips Dynamic Type")
        #expect(!item.contains("G.Row.oneLine") && !style.contains("G.Row.oneLine"))
    }

    @Test func theIOSItemSelectsWithThePanelFillAHairlineAndTheMarker() throws {
        let style = try files.source("iOS/SidebarItemStyle+iOS.swift")
        #expect(style.contains("G.panel"))
        #expect(style.contains("G.border"))
        #expect(style.contains(".selectedMarker("))
        #expect(style.contains("G.Hover.pressed"))
    }

    @Test func theIOSItemSpeaksOneNameTheCountAndTheSelectedTrait() throws {
        let item = try files.source("iOS/SidebarItem+iOS.swift")
        #expect(item.contains(".accessibilityLabel(title)"))
        #expect(item.contains(".accessibilityValue(spokenValue)"))
        #expect(item.contains(".accessibilityAddTraits(isSelected ? .isSelected : [])"))
        #expect(item.contains(".accessibilityHidden(true)"))
    }

    @Test func theIOSItemTakesItsSizesFromTokensOnly() throws {
        for file in ["iOS/SidebarItem+iOS.swift", "iOS/SidebarItemStyle+iOS.swift"] {
            let text = try files.source(file)
            #expect(text.range(of: "cornerRadius: *[0-9]", options: .regularExpression) == nil, "\(file) has a literal radius")
            #expect(text.range(of: "\\.padding\\((\\.[A-Za-z]+, *)?[0-9]", options: .regularExpression) == nil, "\(file) has a literal padding")
        }
    }
}
