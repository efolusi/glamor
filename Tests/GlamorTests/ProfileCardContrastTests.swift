#if os(macOS)
import SwiftUI
import Testing
@testable import Glamor

/// GL37: every colour pair the profile card draws, in light, dark and both with Increase contrast. Text holds 4.5:1.
/// The avatar circle is a soft tile by the token design (`avatarBg` is 1.06:1 off the window in light): the initial is
/// what says who it is, so the initial's pair is the one that is gated, not the circle's edge.
@MainActor
struct ProfileCardContrastTests {
    private func holds(_ ink: Color, on ground: Color, _ need: Double, dark: Bool, high: Bool) {
        let r = ColorMeasure.ratio(ink, ground, dark: dark, high: high)
        #expect(r >= need, "ratio \(r) is under \(need) (dark \(dark), increased \(high))")
    }

    @Test(arguments: ColorMeasure.allModes) func theInitialReadsOnTheAvatarFill(dark: Bool, high: Bool) {
        holds(G.onAvatar, on: G.avatar, 4.5, dark: dark, high: high)
    }

    /// The name is `text`, the detail `text2`: at rest on the window, under the pointer on `cardHover`, pressed.
    @Test(arguments: ColorMeasure.allModes) func theNameAndTheDetailReadAtRestUnderThePointerAndPressed(dark: Bool, high: Bool) {
        for ground in [G.window, G.cardHover, G.Hover.pressed] {
            holds(G.text, on: ground, 4.5, dark: dark, high: high)
            holds(G.text2, on: ground, 4.5, dark: dark, high: high)
        }
    }

    /// The chevron is a mark that says "a menu opens": `text3` holds 3:1 on all three grounds.
    @Test(arguments: ColorMeasure.allModes) func theChevronStandsThreeToOneOffEveryGroundTheCardTakes(dark: Bool, high: Bool) {
        for ground in [G.window, G.cardHover, G.Hover.pressed] {
            holds(G.text3, on: ground, 3, dark: dark, high: high)
        }
    }
}
#endif
