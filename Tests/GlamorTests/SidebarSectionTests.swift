#if os(macOS)
import Foundation
import SwiftUI
import Testing
@testable import Glamor

/// GL33: `SidebarSection`. The look and the key walk are proven in a real window (scene `sidebar-a`); these pin the
/// interface, the words VoiceOver gets, and the source shape the window check relies on.
@MainActor
struct SidebarSectionTests {
    private func source(_ path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent("Sources/Glamor").appendingPathComponent(path), encoding: .utf8)
    }

    @Test func theOpenStateOfASectionIsKeptUnderOneKeyPerId() {
        #expect(SidebarSection<EmptyView>.storageKey(id: "targets") == "glamor.sidebar.section.targets")
        #expect(SidebarSection<EmptyView>.storageKey(id: "across") != SidebarSection<EmptyView>.storageKey(id: "targets"))
    }

    /// Two sidebars in one scene (the main window's and a second column) may both have a "targets" section.
    @Test func aScopeKeepsTwoSidebarsWithTheSameSectionIdApart() {
        #expect(SidebarSection<EmptyView>.storageKey(id: "targets", scope: "main") == "glamor.sidebar.section.main.targets")
        #expect(SidebarSection<EmptyView>.storageKey(id: "targets", scope: "main") != SidebarSection<EmptyView>.storageKey(id: "targets", scope: "rail"))
        #expect(SidebarSection<EmptyView>.storageKey(id: "targets", scope: "main") != SidebarSection<EmptyView>.storageKey(id: "targets"))
        #expect(SidebarSection<EmptyView>.storageKey(id: "targets", scope: nil) == SidebarSection<EmptyView>.storageKey(id: "targets"))
    }

    @Test func aHeaderSaysExpandedOrCollapsedInBothLanguages() {
        #expect(GlamorText.string(.sidebarExpanded, language: "en") == "expanded")
        #expect(GlamorText.string(.sidebarCollapsed, language: "en") == "collapsed")
        #expect(GlamorText.string(.sidebarExpanded, language: "id") == "terbuka")
        #expect(GlamorText.string(.sidebarCollapsed, language: "id") == "tertutup")
    }

    @Test func aHeaderHintSaysItFoldsOrOpensTheSectionInBothLanguages() throws {
        #expect(GlamorText.string(.sidebarSectionHint, language: "en") == "Folds or opens the section")
        #expect(GlamorText.string(.sidebarSectionHint, language: "id") == "Menutup atau membuka bagian")
        #expect(try source("macOS/SidebarSectionBody.swift").contains(".accessibilityHint(GlamorText.string(.sidebarSectionHint))"))
    }

    @Test func theSectionKeepsItsTitleAndTakesTheCallersBinding() {
        var open = true
        let section = SidebarSection("Targets", isExpanded: Binding(get: { open }, set: { open = $0 })) { EmptyView() }
        #expect(section.title == "Targets")
        open = false
    }

    // MARK: A folded section that holds the chosen place

    @Test func aFoldedHeaderNamesTheChosenPlaceInsideItInBothLanguages() {
        #expect(GlamorText.string(.sidebarCollapsedSelected, language: "en", "Host") == "collapsed, Host selected")
        #expect(GlamorText.string(.sidebarCollapsedSelected, language: "id", "Host") == "tertutup, Host dipilih")
    }

    @Test func theHeaderValueIsExpandedCollapsedOrCollapsedWithTheChosenPlace() {
        func value(_ open: Bool, _ chosen: String?, _ language: String) -> String {
            SidebarSectionBody<EmptyView>.headerValue(isExpanded: open, selectedTitle: chosen, language: language)
        }
        #expect(value(true, "Host", "en") == "expanded", "an open section shows its chosen row, so it says nothing more")
        #expect(value(false, nil, "en") == "collapsed")
        #expect(value(false, "Host", "en") == "collapsed, Host selected")
        #expect(value(false, "Host", "id") == "tertutup, Host dipilih")
    }

    @Test func bothInitsTakeTheCueWithDefaultsSoACallerThatDoesNotAskIsUnchanged() {
        var open = false
        let binding = Binding(get: { open }, set: { open = $0 })
        _ = SidebarSection("Targets", isExpanded: binding) { EmptyView() }
        _ = SidebarSection("Targets", isExpanded: binding, containsSelection: true, selectedTitle: "Host") { EmptyView() }
        _ = SidebarSection("Targets", id: "targets") { EmptyView() }
        _ = SidebarSection("Targets", id: "targets", scope: "rail") { EmptyView() }
        _ = SidebarSection("Targets", id: "targets", containsSelection: true, selectedTitle: "Host") { EmptyView() }
        open = true
    }

    /// A folded section draws no rows, so the marker and the panel fill leave with them: the header carries a dot.
    @Test func aFoldedSectionThatHoldsTheChosenPlaceDrawsAHiddenMarkerDotOnItsHeader() throws {
        let text = try source("macOS/SidebarSectionBody.swift")
        #expect(text.contains("!isExpanded && containsSelection"))
        #expect(text.contains("Circle().fill(G.selectedMarker)"))
        #expect(text.contains("G.Dot.d8"))
        let start = try #require(text.range(of: "Circle().fill(G.selectedMarker)"))
        #expect(text[start.upperBound...].prefix(120).contains(".accessibilityHidden(true)"), "VoiceOver gets the words, not the dot")
        #expect(text.contains("headerValue(isExpanded: isExpanded"))
    }

    // MARK: Source shape

    @Test func theHeaderIsAHeaderButtonThatSaysItsStateAndTheTitleAsItWasWritten() throws {
        let text = try source("macOS/SidebarSectionBody.swift")
        #expect(text.contains("Button"))
        #expect(text.contains(".accessibilityAddTraits(.isHeader)"))
        #expect(text.contains(".accessibilityLabel(title)"), "the label keeps the caller's case; the drawn title is upper case")
        #expect(text.contains("GlamorText.string(.sidebarExpanded,"))
        #expect(text.contains("GlamorText.string(.sidebarCollapsed,"))
    }

    /// 32 high like a row, not the 16 high `ListSectionLabel`, and its title starts where a row's name starts.
    @Test func theHeaderHasTheRowsHeightAndItsTextLinesUpWithTheRowNames() throws {
        let text = try source("macOS/SidebarSectionBody.swift")
        #expect(text.contains("SidebarItemStyle(isSelected: false)"), "the same 32 high row, inset and focus ring as an item")
        #expect(text.contains("textStyle(.sectionLabel)"))
        #expect(text.contains(".tracking(G.Font.sectionTracking)"))
        #expect(text.contains(".uppercased()"))
        #expect(text.contains("G.text3"))
    }

    @Test func theChevronTurnsWithTheFastMotionAndJumpsUnderReduceMotion() throws {
        let text = try source("macOS/SidebarSectionBody.swift")
        #expect(text.contains("chevron.right"))
        #expect(text.contains("G.Icon.xs"))
        #expect(text.contains("rotationEffect(.degrees(isExpanded ? 90 : 0))"))
        #expect(text.contains("accessibilityReduceMotion"))
        #expect(text.contains("$0.animation = nil"), "Reduce Motion: the chevron jumps instead of turning")
        #expect(text.contains("withGAnimation(.fast)"))
    }

    /// A collapsed section's rows are not drawn, so they leave the accessibility tree and the Tab order.
    @Test func collapsedRowsAreLeftOutOfTheViewNotJustHidden() throws {
        let text = try source("macOS/SidebarSectionBody.swift")
        #expect(text.contains("if isExpanded"))
        #expect(text.contains(".gTransition(.fade)"))
        #expect(!text.contains(".opacity(isExpanded"))
        #expect(!text.contains(".hidden()"))
    }

    @Test func theIdInitKeepsTheStateInSceneStorageAndTheBindingInitDoesNot() throws {
        let stored = try source("macOS/SidebarSectionStored.swift")
        #expect(stored.contains("@SceneStorage"))
        #expect(stored.contains("SidebarSection<Content>.storageKey(id: id, scope: scope)"))
        #expect(!(try source("macOS/SidebarSection.swift")).contains("@SceneStorage"), "the binding init must work in a bare NSHostingView")
    }
}
#endif
