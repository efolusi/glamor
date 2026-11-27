# Roadmap

The one list of planned work for Glamor. Mark an item `done` or `deferred` (with the reason and what it waits on). Never delete an item.

## Where things stand

Released (tags `v0.0.1` on 2026-11-18, `v0.1.0` on 2026-11-23, `v0.2.0` on 2026-11-27, `v0.3.0` on 2026-11-28):

- One Swift package, one library `Glamor` (macOS 15, iOS 18). Tokens live in `enum G`; Mac files in `Sources/Glamor/macOS/`, iPhone and iPad files in `Sources/Glamor/iOS/` (named `<Name>+iOS.swift`), shared text cleaning in `Sources/Glamor/Text/`.
- No Komando imports. The Komando logo, terminal palette and ANSI colors stay in komando-apps.
- Colors and sizes come from design-tokens through `scripts/vendor-tokens.sh` (v0.8.0 at v0.3.0: the owl's copper accent and `G.accentEdge`); the brand is the same as Meridian's.
- Warm glass on bars, sheets, the theme switch, segments, the search field and the main action. Reduce Transparency, Increase Contrast, macOS 15 and iOS 18 draw the solid path.
- Localisation in English and Indonesian, from one String Catalog, checked by `LocalisationTests`.
- CI on every pull request and push to `main` (`.github/workflows/checks.yml`): vendored tokens, color, motion and size checks, `swift test`, generic iOS build.
- The window check (`scripts/check-window.sh`) runs the gallery on macOS 26 and checks the real window. CI cannot run it, so `scripts/release-gate.sh` runs it on a Mac before a tag.
- Framework: SwiftUI first, Android through Skip later. Token format: DTCG, as Meridian.

What is next:

- GL25: add a default button to the gallery (the Save button of a sheet) and make the window check fail when Return does not press it. Planned for v0.3.1, with GL27 (the switch takes the system tint, not copper) and GL28 (the disabled main action in dark, ProgressBar tones in Increase contrast).
- Items 9 and 10: komando-apps adopts Glamor. Items 7, 15, 16, 18, 20 and 23 wait on it.
- Items 12, 17 and 21: shared preview cards and design moved out of komando-apps, after the plan with the komando coordinator.

What waits on what:

- GL02 (glamor.efolusi.com as a Cloudflare Worker) waits on the owner for DNS and the token scope.
- GL06 (Decor tests and cost) waits on the next design generation, which changes tokens.
- Items 13 and 14 (Android through Skip, Windows and Linux) are deferred, see the table.

## How Glamor consumes design-tokens

1. design-tokens owns `tokens.json`. Glamor stops keeping its own copy.
2. A design-tokens generator writes `tokens/native/GlamorTokens.swift`: plain values only (hex `UInt32` light/dark/increased-contrast sets, sizes, durations). No AppKit, UIKit, or SwiftUI imports.
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
| 3 | Swift generator: `tokens/native/GlamorTokens.swift` | design-tokens | done | v0.0.1 |
| 4 | Add `Package.swift` and the `Glamor` library | glamor | done | |
| 5 | Remove `KomandoKit` / `KomandoMobileCore` imports | glamor | done | |
| 6 | Merge `K` and `MK` into one namespace (`G`; motion helpers `gAnimation`, `gTransition`, `withGAnimation`) | glamor | done | |
| 7 | Vendor generated tokens (done: `scripts/vendor-tokens.sh`, design-tokens v0.7.0, pinned to the tag commit; every new tag is re-vendored here and in Meridian before either releases, see the [rule](https://github.com/efolusi/design-tokens/blob/main/docs/consumers.md#releasing-a-new-version)); wire `G` to them through the Komando override; remove the root `tokens.json` copy | glamor | open | 9 (override file in komando-apps); `tokens.json` stays while `design-preview.py` reads it |
| 8 | Unit tests that build on macOS and the iOS Simulator | glamor | done | |
| 9 | komando-apps Mac app uses Glamor | komando-apps | open | 5, 6 |
| 10 | komando-apps iPhone and iPad app uses Glamor | komando-apps | open | 5, 6 |
| 11 | First Glamor tag `v0.1.0` | glamor | done | v0.1.0 |
| 12 | Turn Komando-specific preview cards into shared primitives | glamor | open | 4 |
| 13 | Android through Skip | glamor | deferred | after Apple apps adopt Glamor |
| 14 | Windows and Linux | glamor | deferred | no framework covers SwiftUI there yet |
| 15 | Move Komando-only tokens back to komando-apps | komando-apps | open | 3 |
| 16 | Move Komando-only sizes out of `G` (`Width.hostName`, `connName`, named `Resize` areas, window sizes) | glamor, komando-apps | open | 9 |
| 17 | Rename `K.`/`MK.` to `G.` in `components/` cards | glamor | open | Komando-specific cards decision (12) |
| 18 | Same token names on Mac and iOS where the meaning is the same (done: `G.Opacity`, `increased:`, `G.Space`, `G.Icon`; open: fonts) | glamor | open | 9, 10 |
| 19 | Apache-2.0 license | glamor | done | |
| 20 | Shared missing roles and increased-contrast pairs in design-tokens (branch tokens/native-roles); Komando values as an override file in komando-apps, applied by the Glamor generator (coordinator decision 2026-11-18, no `native` theme) | design-tokens, glamor, komando-apps | open | design-tokens session |
| 21 | Phase 2: move design (Page cards, components/bundle.js) out of komando-apps into Glamor | glamor, komando-apps | open | plan agreed with the komando coordinator |
| 22 | Glamor's own logo (the Komando icon and logo guide were removed; the AppLogo card leaves with item 12) | glamor | done (assets/glamor.svg) | a design |
| 23 | Rename env vars `KOMANDO_APP_SNAPSHOT` / `KOMANDO_APP_SCROLL` to `GLAMOR_SNAPSHOT` / `GLAMOR_SCROLL`, in Glamor and komando-apps' scripts together, no alias (coordinator 2026-11-18) | glamor, komando-apps | open | 9 |
| 24 | Remove the obsolete `tokens/` folder and its README and ARCHITECTURE rows (design-tokens owns exports) | glamor | done | |
