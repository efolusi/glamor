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

    /// The foot is ONE bordered account card: at rest the row is the card fill with a `border` hairline, as the sso rail foot is;
    /// under the pointer it turns `cardHover`, pressed `G.Hover.pressed`. It casts no shadow, which would lift the foot off the window.
    @Test func atRestTheRowIsTheCardFillAndUnderThePointerItTurnsCardHoverThenPressed() throws {
        #expect(ProfileCardButtonStyle.fill(pressed: false, hover: false) == G.card)
        #expect(ProfileCardButtonStyle.fill(pressed: false, hover: true) == G.cardHover)
        #expect(ProfileCardButtonStyle.fill(pressed: true, hover: true) == G.Hover.pressed)
        #expect(ProfileCardButtonStyle.fill(pressed: true, hover: false) == G.Hover.pressed)
        let style = try source("macOS/ProfileCardButtonStyle.swift")
        #expect(!style.contains(".shadow("))
        #expect(try source("macOS/ProfileCard.swift").contains("G.Width.profileMenu"), "the popover is the profile menu's 260 wide")
    }

    @Test func theRowIsABorderedCardOfTheCardRadiusAndItsFocusRingFollowsThatShape() throws {
        let style = try source("macOS/ProfileCardButtonStyle.swift")
        #expect(style.contains("G.Radius.r12"), "a card's 12, not a list row's 8")
        #expect(style.contains("strokeBorder(G.border, lineWidth: G.Line.hair)"))
        #expect(style.contains("focusRingInside(radius: G.Radius.r12)"), "the ring is drawn on the card's corners")
    }

    /// The circle is a soft tile, 1.06:1 off the window in light: a `border` hairline gives it its boundary (WCAG 1.4.11),
    /// in the rail where it stands alone and in the row, so it is one avatar.
    @Test func theAvatarCircleHasAHairlineRingInBothStyles() throws {
        let card = try source("macOS/ProfileCard.swift")
        #expect(card.contains("Circle().strokeBorder(G.border, lineWidth: G.Line.hair)"))
    }

    @Test func theMenuIsAPopoverTheInitialIsHiddenAndTheButtonHasOneName() throws {
        let card = try source("macOS/ProfileCard.swift")
        #expect(card.contains(".popover(isPresented:"))
        #expect(card.contains(".accessibilityLabel(spokenName)"))
        #expect(card.contains(".accessibilityHidden(true)"), "the initial and the chevron are not read a second time")
    }

    /// On macOS a tooltip is the control's AXHelp, which VoiceOver reads after its name. The card's name is in the tooltip
    /// of the label (hidden from VoiceOver), not of the button: nothing between the button's style and its popover may
    /// call `.help`. The window check reads AXHelp of the button and fails when it is not empty.
    @Test func noTooltipEqualsTheAccessibilityLabelBecauseTheButtonHasNoHelpOfItsOwn() throws {
        let card = try source("macOS/ProfileCard.swift")
        let chain = try #require(card.range(of: ".buttonStyle(ProfileCardButtonStyle(style: style))"))
        let end = try #require(card.range(of: ".popover(isPresented:"))
        let onTheButton = String(card[chain.upperBound..<end.lowerBound])
        #expect(!onTheButton.contains(".help("), "a tooltip on the button is read a second time as its help text")
        let label = try #require(card.range(of: "Button { isOpen.toggle() } label: {"))
        let labelEnd = try #require(card.range(of: ".buttonStyle(ProfileCardButtonStyle"))
        let inTheLabel = String(card[label.upperBound..<labelEnd.lowerBound])
        #expect(inTheLabel.contains(".help(spokenName)"), "the name is the tooltip of the label")
        #expect(inTheLabel.contains(".accessibilityHidden(true)"), "and that label is hidden from VoiceOver")
    }

    @Test func theAvatarStyleIsAtLeast44SquareAndTheRowIsTheRowRadius() throws {
        let style = try source("macOS/ProfileCardButtonStyle.swift")
        #expect(style.contains("G.Height.toolbar"), "the rail's avatar is a 44 point target")
        #expect(style.contains("focusRingCapsule()"), "a square 44 target is a circle: the capsule ring")
    }
}
#endif
