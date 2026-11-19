# Changelog

## Unreleased

- **`guidelines/overview.md` covers Glamor only.** Its komando sections (Platforms with the iPhone and iPad notes, Editions, Screens and Agent mode) are cut; komando-apps' `design/README.md` holds a newer copy, and one line points there.
- **komando's journeys and UX review moved out.** `guidelines/journeys.md` and `guidelines/ux-review.md` were komando's product docs; they live in efolusi/komando-apps `design/`.
- **Breaking: icon sizes use the design-tokens names.** `G.Icon.i8`, `i12`, `i16`, `i20`, `i24` and `i32` are now `G.Icon.xs`, `sm`, `md`, `lg`, `xl` and `xxl`, with no alias. `xxl` is `icon.2xl`, because a Swift name cannot start with a digit. The sizes come from the vendored design-tokens v0.2.0, and the docs and `tokens.json` use `icon-xs` to `icon-2xl`.
- **Breaking: `TextFieldBox` needs a `label`.** It was optional and fell back to the placeholder, which a screen reader then read as the field's name. Pass the visible label's text.
- **Tokens come from design-tokens v0.2.0** (`scripts/vendor-tokens.sh`), which adds control, icon, avatar and sidebar sizes.
- The copy button has an accessible name, the README lists the platforms, and the previews use no em dashes.

## 0.0.1 — 2026-11-18

- First release: SwiftUI components, guidelines and previews, with tokens vendored from design-tokens.
