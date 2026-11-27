#if os(macOS)
import SwiftUI
import Testing
@testable import Glamor

/// GL45: a banner's tint for the contrast in force, like a pill's: the same 10% as a pill at normal contrast, and the
/// pill's and tile's stronger tint with Increase contrast, so the banner's shape stands out from the card.
struct BannerOpacityTests {
    @Test func aBannerTintIsTheConstantAtNormalContrast() {
        #expect(G.Opacity.banner(.standard) == G.Opacity.banner)
    }

    @Test func aBannerTintIsStrongerWithIncreaseContrast() {
        #expect(G.Opacity.banner(.increased) == G.Opacity.increased)
        #expect(G.Opacity.increased > G.Opacity.banner)
    }
}
#endif
