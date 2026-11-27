#if os(macOS)
import Foundation
import SwiftUI
import Testing
@testable import Glamor

/// GL37: `ProfileCard`. The look and the popover are proven in a real window (scene `profile`); these pin the words
/// VoiceOver gets, the initial, and the source shape the window check depends on.
@MainActor
struct ProfileCardTests {
    private func source(_ path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent("Sources/Glamor").appendingPathComponent(path), encoding: .utf8)
    }

    private func card(_ name: String, _ detail: String = "Local · on this Mac", style: ProfileCardStyle = .row) -> ProfileCard<EmptyView> {
        ProfileCard(name: name, detail: detail, style: style) { EmptyView() }
    }

    // MARK: Words

    @Test func theCardIsOneButtonNamedByTheNameThenTheDetail() {
        #expect(card("Alex", "Local · on this Mac").spokenName == "Alex, Local · on this Mac")
        #expect(card("Alex", "Local · on this Mac", style: .avatar).spokenName == "Alex, Local · on this Mac", "the avatar says the same")
    }

    @Test func aCardWithNoDetailIsNamedByTheNameAlone() {
        #expect(card("Alex", "").spokenName == "Alex")
    }

    @Test func theInitialIsTheFirstLetterInCapitals() {
        #expect(card("alex").initial == "A")
        #expect(card("  Rina Putri").initial == "R")
        #expect(card("élodie").initial == "É")
    }

    @Test func aCardWithNoNameShowsNoInitial() {
        #expect(card("").initial == nil)
        #expect(card("   ").initial == nil)
    }

    @Test func theRowIsTheDefaultStyle() {
        let c = ProfileCard(name: "Alex", detail: "Local") { EmptyView() }
        #expect(c.style == .row)
    }

    // MARK: Source shape

    @Test func theRowIsTwoLinesHighWithATileAvatarAndTheTokenFonts() throws {
        let card = try source("macOS/ProfileCard.swift")
        #expect(try source("macOS/ProfileCardButtonStyle.swift").contains("G.Height.row52"))
        #expect(card.contains("G.Tile.t32"))
        #expect(card.contains("G.avatar"))
        #expect(card.contains("G.onAvatar"))
        #expect(card.contains(".textStyle(.bodyMedium)"))
        #expect(card.contains(".textStyle(.caption)"))
        #expect(card.contains("chevron.up.chevron.down"))
        #expect(card.contains("G.Icon.sm"))
        #expect(card.contains("G.text2"))
        #expect(card.contains("G.text3"))
    }

    /// Under the pointer the card is a raised control: `cardHover`, then `G.Hover.pressed`. It casts no shadow, which
    /// would lift the sidebar's footer off the window.
    @Test func underThePointerItTurnsCardHoverThenPressedAndCastsNoShadow() throws {
        let style = try source("macOS/ProfileCardButtonStyle.swift")
        #expect(style.contains("G.cardHover"))
        #expect(style.contains("G.Hover.pressed"))
        #expect(!style.contains(".shadow("))
        #expect(try source("macOS/ProfileCard.swift").contains("G.Width.profileMenu"), "the popover is the profile menu's 260 wide")
    }

    @Test func theMenuIsAPopoverTheInitialIsHiddenAndTheButtonHasOneName() throws {
        let card = try source("macOS/ProfileCard.swift")
        #expect(card.contains(".popover(isPresented:"))
        #expect(card.contains(".accessibilityLabel(spokenName)"))
        #expect(card.contains(".help(spokenName)"))
        #expect(card.contains(".accessibilityHidden(true)"), "the initial and the chevron are not read a second time")
    }

    @Test func theAvatarStyleIsAtLeast44SquareAndTheRowIsTheRowRadius() throws {
        let style = try source("macOS/ProfileCardButtonStyle.swift")
        #expect(style.contains("G.Height.toolbar"), "the rail's avatar is a 44 point target")
        #expect(style.contains("G.Row.radius"))
        #expect(style.contains("focusRingCapsule()"), "a square 44 target is a circle: the capsule ring")
    }
}
#endif
