# Changelog

## Unreleased

- **Docs: glass turns grey when the window is not key (GL20).** The README now says this is the system's inactive glass state and expected: Deploy, the segments and the theme switch lose their tint until the window is key. No behaviour changed.

## v0.1.0 - 2026-11-23

- **New: warm glass (GL13).** System glass behind `#available(iOS 26, macOS 26, *)` on bars and sheets, `.glass` on the theme switch, the segmented control and the search field, and a tinted ember glass for the main action. Reduce Transparency and Increase Contrast swap to the solid path, which is also what macOS 15 and iOS 18 draw. Materials come from design-tokens v0.7.0 (`scripts/vendor-tokens.sh`).
- **New: CI (GL15).** `.github/workflows/checks.yml` runs on every pull request and every push to `main`, on GitHub-hosted runners: the vendored tokens check, the colour, motion and size checks, `swift test`, and the generic iOS build.
- **New: the window check (`scripts/check-window.sh`).** Runs `GlamorGallery` on macOS 26 and checks the real window with no person at the keyboard: contrast in pixels, the label-to-icon gap, VoiceOver strings and `AXPress`, Tab order, Space and Return. It captures only that window and changes no system setting. `scripts/release-gate.sh` runs it after the CI checks; CI does not run it.
- **Fix: the search placeholder is readable on glass (GL18).** New `G.placeholder` (design-tokens `textMuted`): `SearchBar` and `FilterField` draw their placeholder in it instead of the system's colour. ContrastTests hold it at 4.5:1 or more on every surface a field sits on and on glass over them, light and dark (lowest 5.48:1).
- **Fix: the main action's label reads on its ember fill (GL19).** `glassMainAction` no longer uses the system's `.glassProminent`, whose own label colour was light on the dark theme's ember (2.05:1). It draws its own tinted glass and sets the label to `G.onAccent`: white on the light ember (5.24:1), the dark ink on the dark ember (8.43:1). The shape is the solid primary button's (32 high, `r8`), no longer a capsule.
- **Fix: one gap between a label and its icon (GL21).** New `G.Space.labelIcon` (design-tokens `space-2`, 8) is the gap in every control that pairs text with an icon: `MenuPicker` (its chevron was the system's, about 3 pt from the title; it is now drawn 8 away with `.menuIndicator(.hidden)`), `LinkButton` (was 4), button labels, `SearchBar`, `FilterField`, `Banner` and iOS `FailureLine`. `LabelIconGapTests` fails on a literal, another token or SwiftUI's default in any such `HStack` or `Label`.
- **Breaking: `ThemeSwitch` needs its words.** `ThemeSwitch(appearance:words:)` has no default language any more, so an Indonesian app cannot fall back to English by leaving the words out. Pass `.english`, `.indonesian` or your own `ThemeSwitchWords(toDark:toLight:)` (GL16).
- **The Glamor logo is the logo-system file.** `assets/glamor.svg` is replaced byte for byte by the approved file (sha256 starts 942628b8a9a6): the same lipstick, now on the 64 artboard in the tall box, one path. The README names `efolusi/efolusi` as the source of the marks.
- **Breaking: the theme switch offers light and dark only.** `Appearance.system` is removed, with no alias, and `Appearance.scheme` is no longer optional. New: `Appearance.start(stored:deviceIsDark:)` returns the stored choice, or the device's theme on a first launch (an old stored "System" also follows the device). Store the person's choice after they switch.
- **New: the Glamor logo, `assets/glamor.svg`.** A leaning lipstick (one slanted tip, a collar, a base) at the angle of Meridian's bars, one colour, tight viewBox (ratio 0.863). It is the mark `efolusi.com` shows for Glamor.
- **New: haptic tokens.** `GHaptic` (`selection`, `fast`, `base`, `success`, `warning`, `error`) and `View.gHaptic(_:trigger:)`. `fast` and `base` match the two motion sizes (`GHaptic(PhoneMotion.Token)`). iPhone and iPad play them, and the system leaves them out when System Haptics is off. With Reduce Motion `base` softens to `fast`. On the Mac the modifier does nothing.
- **New: `Decor`, decorative backdrops.** `Decor(.mesh | .noise | .grid | .dots, fade:)` draws a backdrop behind a hero or section from the accent and text colours, as Meridian's `Decor`. It is hidden from VoiceOver, takes no touches, never moves (so Reduce Motion has nothing to stop) and is left out under Increase Contrast. Use `G.text` or `G.text2` for text over it, not `G.text3`.
- **Tokens come from design-tokens v0.5.0** (pin equal to Meridian). It adds the info colours, the status background, border, text, solid and on-solid colours, `surfaceTrack`, `surfaceBrandHover`, `textDisabled`, `borderHover`, the warm accents and the loop durations `durLoop` and `durLoopSlow`. Nothing Glamor uses was removed.
- **Row dividers stop where a row's highlight stops.** A CardList's hairlines are now inset `G.Row.cardInset` from the card's right edge as well as from the left, so they no longer run into the card's border.
- **A selected row shows a capsule, not a sliver.** The selected marker is 4 wide, 60% of the row's height, centred and 4 in from the leading edge (`G.Row.markerWidth`, `markerHeight`, `markerInset`); it was a 2pt bar on the very edge. `rowLook` insets its highlight like a ListRow, and ContrastTests check that the selected fill shows against the card.
- **`guidelines/overview.md` is Glamor's own.** Layout rules, copy examples, the icon table and the owner answers no longer use komando's places, words or glyphs; In Swift describes Glamor's `G` and the vendored `GlamorTokens`. Values name their design-tokens token, and contrast ratios point to the contrast tests.
- **`guidelines/overview.md` covers Glamor only.** Its komando sections (Platforms with the iPhone and iPad notes, Editions, Screens and Agent mode) are cut; komando-apps' `design/README.md` holds a newer copy, and one line points there.
- **komando's journeys and UX review moved out.** `guidelines/journeys.md` and `guidelines/ux-review.md` were komando's product docs; they live in efolusi/komando-apps `design/`.
- **Breaking: icon sizes use the design-tokens names.** `G.Icon.i8`, `i12`, `i16`, `i20`, `i24` and `i32` are now `G.Icon.xs`, `sm`, `md`, `lg`, `xl` and `xxl`, with no alias. `xxl` is `icon.2xl`, because a Swift name cannot start with a digit. The sizes come from the vendored design-tokens v0.2.0, and the docs and `tokens.json` use `icon-xs` to `icon-2xl`.
- **Breaking: `TextFieldBox` needs a `label`.** It was optional and fell back to the placeholder, which a screen reader then read as the field's name. Pass the visible label's text.
- **Breaking: one brand with Meridian.** Every colour and text size comes from design-tokens v0.2.1 (`scripts/vendor-tokens.sh`), the warm brown palette Meridian uses; no colour is typed in Glamor any more.
  - `G.accent` is the ink fill of the main button, a progress bar and a switch; it was blue. `G.primary`, `primaryHover`, `primaryPressed` and `onPrimary` are now `G.accent`, `accentHover`, `accentPressed` and `onAccent`, with no alias.
  - New: `G.accentSubtle` (a chosen row's fill, always with the marker), `G.accentFg` (the brand's brown for glyphs on a tint) and `G.link`. `G.focus` and `G.selectedMarker` are brown.
  - `G.avatar` is a sand fill with a dark initial (`G.onAvatar`); it was green with white.
  - `Color(hex:)`, `NSColor(hex:)`, `UIColor(hex:)` and `Color.adaptive(_:_:increased:)` are removed; use `Color(GlamorTokens.ColorPair)`.
  - Mac titles are 21, 18 and 16 (were 20, 17 and 15), the design-tokens text sizes.
- **Tokens come from design-tokens v0.2.1**, which adds control, icon, avatar and sidebar sizes (0.2.0) and fixes the palette's own contrast (0.2.1).
- The copy button has an accessible name, the README lists the platforms, and the previews use no em dashes.

## v0.0.1 - 2026-11-18

- First release: SwiftUI components, guidelines and previews, with tokens vendored from design-tokens.
