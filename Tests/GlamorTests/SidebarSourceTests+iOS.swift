import Foundation
import Testing

/// GL39: the shape of the 44 high `SidebarItem` on iOS. An iOS test target cannot run in `swift test`, so these
/// read the source, which runs on the Mac (`SidebarItemTestsIOS` holds the behaviour; it needs an iOS simulator run).
struct SidebarSourceTestsIOS {
    private let files = TokenSource()

    @Test func theIOSItemHasTheSameTwoInitsAsTheMac() throws {
        let ios = try files.code("iOS/SidebarItem+iOS.swift")
        #expect(ios.contains("public init(_ title: String, symbol: String, isSelected: Bool,"))
        #expect(ios.contains("public init(place: Place, selection: Binding<Place.ID>, count: SidebarCount? = nil)"))
    }

    @Test func theIOSItemIsAtLeastATouchTargetHighAndGrowsWithText() throws {
        let item = try files.code("iOS/SidebarItem+iOS.swift"), style = try files.code("iOS/SidebarItemStyle+iOS.swift")
        #expect(style.contains("static let minHeight = G.touch"))
        #expect(style.contains("minHeight: Self.minHeight"))
        #expect(!style.contains("maxHeight"), "a row that cannot grow clips Dynamic Type")
        #expect(!item.contains("G.Row.oneLine") && !style.contains("G.Row.oneLine"))
    }

    @Test func theIOSItemSelectsWithThePanelFillAHairlineAndTheMarker() throws {
        let style = try files.code("iOS/SidebarItemStyle+iOS.swift")
        #expect(style.contains("isSelected ? G.panel"))
        #expect(style.contains("strokeBorder(G.border"))
        #expect(style.contains(".selectedMarker(isSelected)"))
        #expect(style.contains("configuration.isPressed ? G.Hover.pressed"))
    }

    @Test func theIOSItemSpeaksOneNameTheCountAndTheSelectedTrait() throws {
        let item = try files.code("iOS/SidebarItem+iOS.swift")
        #expect(item.contains(".accessibilityLabel(title)"))
        #expect(item.contains(".accessibilityValue(spokenValue)"))
        #expect(item.contains(".accessibilityAddTraits(isSelected ? .isSelected : [])"))
        let symbol = try #require(item.range(of: "Image(systemName: symbol)"))
        #expect(item[symbol.upperBound...].prefix(80).contains(".accessibilityHidden(true)"), "the symbol is not read")
        let pill = try #require(item.range(of: "in: Capsule())"))
        #expect(item[pill.upperBound...].prefix(60).contains(".accessibilityHidden(true)"), "the count pill is spoken through the value, not twice")
    }

    /// On iPadOS a tooltip is the control's accessibility hint, so the row's own name as help on the whole button would be read
    /// a second time. Without a `help` the name's tooltip sits on the text, which VoiceOver skips; the Mac does the same.
    @Test func theRowSetsHelpOnlyWhenThereIsOneAndTheNameTooltipIsHiddenFromVoiceOver() throws {
        let item = try files.code("iOS/SidebarItem+iOS.swift")
        #expect(!item.contains(".help(tooltip)"), "the title as help on the button is read a second time")
        #expect(item.contains(".help(ifPresent: rowHelp)"))
        let name = try #require(item.range(of: ".help(ifPresent: nameTooltip)"))
        #expect(item[name.upperBound...].prefix(60).contains(".accessibilityHidden(true)"), "the name's tooltip sits on text VoiceOver skips")
    }

    /// A long name wraps at large text sizes; the count keeps its own width instead of being squeezed to "1…".
    @Test func theCountPillKeepsItsWidthWhenALongNameWraps() throws {
        let item = try files.code("iOS/SidebarItem+iOS.swift")
        let pill = try #require(item.range(of: "Text(count.value, format: .number)"))
        let background = try #require(item.range(of: ".background(G.accentSubtle", range: pill.upperBound..<item.endIndex))
        #expect(item[pill.upperBound..<background.lowerBound].contains(".fixedSize()"))
    }

    /// The Mac keeps these fields internal; a public field on one platform only would make the two APIs differ.
    @Test func theIOSItemsFieldsAreInternalAsOnTheMac() throws {
        let item = try files.code("iOS/SidebarItem+iOS.swift")
        #expect(!item.contains("public let"), "SidebarItem's fields are internal on the Mac")
        #expect(item.contains("\n    let title: String"))
    }

    @Test func theIOSItemTakesItsSizesFromTokensOnly() throws {
        for file in ["iOS/SidebarItem+iOS.swift", "iOS/SidebarItemStyle+iOS.swift"] {
            let text = try files.code(file)
            #expect(text.range(of: "cornerRadius: *[0-9]", options: .regularExpression) == nil, "\(file) has a literal radius")
            #expect(text.range(of: "\\.padding\\((\\.[A-Za-z]+, *)?[0-9]", options: .regularExpression) == nil, "\(file) has a literal padding")
        }
    }
}
