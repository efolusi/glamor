# Changelog

## Unreleased

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

## 0.0.1 — 2026-11-18

- First release: SwiftUI components, guidelines and previews, with tokens vendored from design-tokens.
