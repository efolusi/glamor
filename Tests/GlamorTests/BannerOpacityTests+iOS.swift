#if os(iOS)
import SwiftUI
import Testing
@testable import Glamor

/// GL45 on iOS: the same two facts as `BannerOpacityTests` on the Mac.
struct BannerOpacityTestsIOS {
    @Test func aBannerTintIsTheConstantAtNormalContrast() {
        #expect(G.Opacity.banner(.standard) == G.Opacity.banner)
    }

    @Test func aBannerTintIsStrongerWithIncreaseContrast() {
        #expect(G.Opacity.banner(.increased) == G.Opacity.increased)
        #expect(G.Opacity.increased > G.Opacity.banner)
    }
}
#endif
