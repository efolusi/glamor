import SwiftUI

public extension G {
    /// The shape of every button: a capsule, so the corner is half the height (a circle for an icon-only button
    /// as wide as it is high). `PrimaryButtonStyle`, `SecondaryButtonStyle`, `GhostButtonStyle`, the glass main
    /// action, `MenuPicker` and the `MoreMenu` hover all draw this one value, so a button drawn by hand beside
    /// them uses it too (with `.focusRingCapsule()`). Fields, rows, banners and the segmented control keep their
    /// radius and do not use it (GL41).
    static var controlShape: Capsule { Capsule() }
}
