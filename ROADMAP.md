# Roadmap

The one list of planned work for Glamor. Mark an item `done` or `deferred` (with the reason and what it waits on). Never delete an item.

## Where things stand (2026-11-18)

- `Sources/DesignSystem/` and `Sources/DesignSystemMobile/` are exact copies of komando-apps. They import `KomandoKit` and `KomandoMobileCore`, so they do not build on their own.
- There is no `Package.swift` yet.
- `tokens.json` here and in design-tokens hold the same colors. Two copies of one fact.
- Framework: SwiftUI-first; Android through Skip later (decided 2026-11-18).
- Token format: DTCG, as Meridian already produces (decided 2026-11-18). Komando-only tokens go back to komando-apps.

## How Glamor consumes design-tokens

1. design-tokens owns `tokens.json`. Glamor stops keeping its own copy.
2. A design-tokens generator writes `tokens/native/swift/GlamorTokens.swift`: plain values only (hex `UInt32` light/dark/increased-contrast sets, sizes, durations). No AppKit, UIKit, or SwiftUI imports.
3. Glamor vendors that file into `Sources/Glamor/Generated/` with a script and a check that fails when it is stale.
4. Glamor's own `Tokens.swift` turns those values into `Color` and layout constants per platform (AppKit on Mac, UIKit on iPhone and iPad).
5. Names stay the same as on the web (Meridian). Only values may differ by theme or density.

## How komando-apps adopts Glamor

1. Glamor gets one Swift package with one library, `Glamor`, for macOS 15 and iOS 18. Mac-only and iOS-only parts sit behind `#if os(...)`.
2. Remove the Komando ties: `KomandoError` becomes a small error protocol; the Komando logo stays in the app.
3. Merge `K` (Mac) and `MK` (iPhone/iPad) into one token namespace, with density per idiom.
4. komando-apps adds Glamor as a SwiftPM dependency (local path while developing, a tagged version for releases).
5. Delete `Apps/macOS/Sources/Komando/DesignSystem/` and `Apps/iOS/KomandoMobile.swiftpm/Sources/DesignSystem/`, and rename every caller in the same change. No aliases.
6. The check scripts (`check-colors.sh`, `check-sizes.sh`, `check-motion.sh`) move to Glamor or read Glamor's names.
7. iPad uses the iOS target with size classes; no separate app.

## Planned work

| # | Item | Repo | Status | Waits on |
|---|---|---|---|---|
| 1 | Decide the framework path: SwiftUI-first, Skip later for Android | glamor | done | |
| 2 | Pick one token format shared with Meridian: DTCG | design-tokens | done | |
| 3 | Swift generator: `tokens/native/swift/GlamorTokens.swift` | design-tokens | open | 2 |
| 4 | Add `Package.swift` and the `Glamor` library | glamor | open | 1 |
| 5 | Remove `KomandoKit` / `KomandoMobileCore` imports | glamor | open | 4 |
| 6 | Merge `K` and `MK` into one namespace | glamor | open | 4 |
| 7 | Vendor generated tokens; remove the root `tokens.json` copy | glamor | open | 3 |
| 8 | Unit tests that build on macOS and the iOS Simulator | glamor | open | 5 |
| 9 | komando-apps Mac app uses Glamor | komando-apps | open | 5, 6 |
| 10 | komando-apps iPhone and iPad app uses Glamor | komando-apps | open | 5, 6 |
| 11 | First Glamor tag `0.0.1` | glamor | open | owner's yes, 8 |
| 12 | Turn Komando-specific preview cards into shared primitives | glamor | open | 4 |
| 13 | Android through Skip | glamor | deferred | after Apple apps adopt Glamor |
| 14 | Windows and Linux | glamor | deferred | no framework covers SwiftUI there yet |
| 15 | Move Komando-only tokens back to komando-apps | komando-apps | open | 3 |
