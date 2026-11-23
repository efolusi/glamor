#if os(macOS)
import SwiftUI
import Testing
import Glamor

/// The theme switch has two choices, light and dark. A first launch follows the device; after that the person's choice is kept.
struct AppearanceTests {
    @Test func offersLightAndDarkOnly() {
        #expect(Appearance.allCases == [.light, .dark])
        #expect(Appearance(rawValue: "System") == nil)
    }

    @Test func eachChoiceMapsToItsColorScheme() {
        #expect(Appearance.light.scheme == .light)
        #expect(Appearance.dark.scheme == .dark)
    }

    @Test func firstLaunchFollowsTheDevice() {
        #expect(Appearance.start(stored: nil, deviceIsDark: true) == .dark)
        #expect(Appearance.start(stored: nil, deviceIsDark: false) == .light)
    }

    @Test func aStoredChoiceIsKept() {
        #expect(Appearance.start(stored: "Light", deviceIsDark: true) == .light)
        #expect(Appearance.start(stored: "Dark", deviceIsDark: false) == .dark)
    }

    @Test func anOldSystemChoiceFallsBackToTheDevice() {
        #expect(Appearance.start(stored: "System", deviceIsDark: true) == .dark)
        #expect(Appearance.start(stored: "System", deviceIsDark: false) == .light)
    }
}
#endif
