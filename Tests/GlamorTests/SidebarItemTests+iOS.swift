#if os(iOS)
import SwiftUI
import Testing
@testable import Glamor

/// GL39: the iOS `SidebarItem`. The interface and the words VoiceOver gets are the Mac's; the row is a touch target
/// high. `SidebarSourceTestsIOS` pins the source shape on the Mac; these need an iOS simulator run (`xcodebuild test`, CONTRIBUTING).
@MainActor
struct SidebarItemTestsIOS {
    private let place = Place(id: "host", title: "Host", symbol: "desktopcomputer")

    @Test func aPlaceGivesTheRowItsTitleAndSymbol() {
        let item = SidebarItem(place: place, selection: .constant("other"))
        #expect(item.title == "Host")
        #expect(item.symbol == "desktopcomputer")
        #expect(item.count == nil)
        #expect(item.help == nil)
    }

    @Test func aPlaceRowIsSelectedWhenTheSelectionIsItsId() {
        var chosen = "other"
        let binding = Binding(get: { chosen }, set: { chosen = $0 })
        #expect(!SidebarItem(place: place, selection: binding).isSelected)
        chosen = "host"
        #expect(SidebarItem(place: place, selection: binding).isSelected)
    }

    @Test func pressingAPlaceRowSelectsItsPlace() {
        var chosen = "other"
        SidebarItem(place: place, selection: Binding(get: { chosen }, set: { chosen = $0 })).action()
        #expect(chosen == "host")
    }

    @Test func aCountedRowSpeaksItsWordsAndAnUncountedOneSpeaksNone() {
        let counted = SidebarItem("Copy", symbol: "doc", isSelected: false,
                                  count: SidebarCount(2, spoken: "2 transfers running"), action: {})
        #expect(counted.spokenValue == "2 transfers running")
        #expect(SidebarItem("Copy", symbol: "doc", isSelected: false, action: {}).spokenValue == "")
    }

    @Test func theHelpIsTheCallersOrElseTheTitle() {
        #expect(SidebarItem("Copy", symbol: "doc", isSelected: false, action: {}).tooltip == "Copy")
        #expect(SidebarItem("Copy", symbol: "doc", isSelected: false, help: "Copy files", action: {}).tooltip == "Copy files")
    }

    @Test func aRowIsNeverShorterThanATouchTarget() {
        #expect(SidebarItemStyle.minHeight == G.touch)
        #expect(SidebarItemStyle.minHeight >= 44)
    }
}
#endif
