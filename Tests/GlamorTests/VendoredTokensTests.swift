import Glamor
import Testing

/// The values vendored from design-tokens are part of Glamor's public API.
struct VendoredTokensTests {
    @Test func sharedRolesAndIncreasedContrastArePresent() {
        let border = GlamorTokens.Color.borderDefault
        #expect(border.increasedLight == GlamorTokens.Color.borderControl.light)
        #expect(GlamorTokens.Length.space05 == 2)
        #expect(GlamorTokens.Length.radiusXsPlus == 6)
        #expect(GlamorTokens.Number.opacityPill == 0.1)
    }
}
