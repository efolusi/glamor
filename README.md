# Glamor

Native design system for Mac, iPhone, and iPad, by [Efolusi](https://efolusi.com), built on SwiftUI. Android, Windows, and Linux are planned (see [ROADMAP.md](ROADMAP.md)).

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-7A4E2B.svg)](LICENSE)

## What's here

| Path | What it is |
|---|---|
| `tokens.json` | Authored tokens (color, type, space, motion, …) |
| `assets/` | Brand files: `glamor.svg`, the logo (one colour, shape only; paint it through a CSS mask). The same file is `public/glamor.svg` on efolusi.com. The marks of all Efolusi products come from `efolusi/efolusi` (`public/<product>.svg`) |
| `components/` | Flat HTML preview cards (`components/<Name>/`) |
| `guidelines/` | Overview, iconography, ecosystem, quality review. komando's journeys and UX review live in efolusi/komando-apps `design/`. |
| `Package.swift` | The `Glamor` library for macOS 15 and iOS 18 |
| `Sources/Glamor/` | SwiftUI tokens (`G`) and components: `macOS/`, `iOS/`, `Text/`, `Decor/` (backdrops), `Haptics/`; `Resources/Localizable.xcstrings` holds the words the library says itself, in English and Indonesian (`scripts/generate-strings.py` writes the `.lproj` files the target ships) |
| `scripts/` | Preview build, color / size / motion checks, the window checks (`check-window.sh`) and the release gate (`release-gate.sh`) |

## Principles

- Neutrals carry the interface; color is for status only.
- One primary action per screen.
- Tokens only: no literal colors or sizes in product views.
- SF Symbols by name; no custom icon set.
- Motion only when it explains a change.
- Same words and status meanings on every platform.
- Every word the library says itself (a VoiceOver name, a tooltip, the default of a text argument) comes from the String Catalog in `en` and `id`. A word a caller owns (a title, a placeholder, `ThemeSwitchWords`) is passed in by the caller; `ThemeSwitchWords.current` reads the catalog.

## Ecosystem

| Repo | Role |
|---|---|
| [design-tokens](https://github.com/efolusi/design-tokens) | Shared tokens |
| [Meridian](https://github.com/efolusi/meridian) | Web (React, CSS, CDN) |
| **Glamor** (this repo) | Native / SwiftUI |

See [guidelines/ecosystem.md](guidelines/ecosystem.md) and [ARCHITECTURE.md](ARCHITECTURE.md).

## Use it

Add Glamor to `Package.swift`, pinned to a tag:

```swift
.package(url: "https://github.com/efolusi/glamor", exact: "0.2.0"),
```

Then add `"Glamor"` to your target's dependencies and `import Glamor`. The newest tag and what changed are in [CHANGELOG.md](CHANGELOG.md).

## Language

The words Glamor says itself (VoiceOver names, tooltips, the Copied announcement, the defaults of `label`, `help` and `allTitle`) live in the String Catalog `Sources/Glamor/Resources/Localizable.xcstrings`, in English (`en`) and Indonesian (`id`). Words your app owns (titles, placeholders, `ThemeSwitchWords`) are passed in by your app.

Your app does not pass a language. Glamor takes the first match, in this order:

1. Your app's languages, ordered for the person (`Bundle.main.preferredLocalizations`). An app in English only stays English on a Mac or iPhone set to Indonesian, so Glamor's words match the app's own.
2. The person's language list (`Locale.preferredLanguages`), when your app has neither English nor Indonesian (an app in French only) or no languages of its own (the gallery under `swift run`).
3. English.

- An app that wants Glamor in Indonesian must offer Indonesian itself: ship an `id.lproj` (a String Catalog with Indonesian makes one) or list `id` in `CFBundleLocalizations`. An app that offers English and not Indonesian always gets English.
- The person picks among your app's languages with the system list, or with the language they set for your app in Settings.
- For a test or a screenshot, start the app with `-AppleLanguages "(id)"`.
- `ThemeSwitchWords.current` gives the theme switch's words in that same language; `.english` and `.indonesian` fix one.
- Glamor reads the language from the process (`Bundle.main`, `Locale.preferredLanguages`) when it builds a word, never from SwiftUI's environment, so `.environment(\.locale, Locale(identifier: "id"))` in a preview does not change Glamor's words. A preview follows the process that hosts it, by the same three steps; to see Glamor's Indonesian in an app that offers it, run the app with `-AppleLanguages "(id)"` or set the Mac's language to Indonesian.

## Preview

```bash
python3 scripts/design-preview.py
```

Opens `build/design-preview/index.html` (gitignored). Cards live under `components/`. The script loads React 18.3.1 from jsDelivr and needs the network.

## Seed

Seeded from `efolusi/komando-apps` on 2026-11-18: design files lifted to this shallow root; Swift design-system trees merged into one `Glamor` library under `Sources/Glamor/`. `komando-apps` was not modified.

Next work: see [ROADMAP.md](ROADMAP.md).

## Window checks

```bash
scripts/check-window.sh            # --strict also fails on UNPROVEN lines
```

Runs `GlamorGallery` on a Mac with macOS 26 and checks the real window, with no person at the keyboard. It
captures only that window (`screencapture -l <window id>`) and reads the accessibility tree and key events of its PID.

| Check | How | Needs |
|---|---|---|
| Search placeholder 4.5:1, Deploy label on its glass fill 4.5:1, unfocused search edge 3:1 (GL17) | pixels of the capture, in light, dark and with the Increase contrast colours | Screen Recording |
| Label-to-icon gap on the "Daily" menu button | ink gap in pixels against 8 pt times the backing scale | Screen Recording |
| VoiceOver strings, role, selected state, target size, `AXPress` | accessibility tree | Accessibility |
| Tab order, Space and Return | key events to the gallery's PID | Accessibility |

Light and dark are the gallery's own `--appearance` argument, and the gallery runs in English (`-AppleLanguages '(en)'`) on a Mac set to any language. The script never changes a system setting. It
cannot set SwiftUI's `accessibilityReduceTransparency` or `colorSchemeContrast` (read-only environment values), so
the solid (non-glass) path is not drawn in a window; the Increase contrast colours are. Tab reaches buttons only
with System Settings › Keyboard › Keyboard navigation on; with it off the Tab order and Space/Return on buttons
print `UNPROVEN`. Exit 0: nothing failed. Exit 1: a check failed. Exit 2: it could not run. Screenshots and tables
go to `GLAMOR_WINDOW_OUT` (default `.build/window-check`). Run it with the Mac idle: one gallery window opens per scenario.

## Release gate

```bash
scripts/release-gate.sh            # --strict also fails on UNPROVEN window lines
```

Runs what CI runs (vendored tokens, colour, size and motion checks, `swift test`, the generic iOS build), then
`scripts/check-window.sh`. Every step runs; each prints `PASS` or `FAIL`, and the window check adds its own
`PASS`, `FAIL` and `UNPROVEN` counts. The window check needs a logged-in macOS 26 session with Accessibility and
Screen Recording permission, so CI does not run it: run the gate on a Mac before a tag, with the 1-minute load
(`uptime`) under 10. Logs go to `GLAMOR_GATE_OUT` (default `.build/release-gate`).

## Glass when the window is not key

On macOS 26, system glass loses its tint when its window is not the key window. The ember Deploy button, the segmented control and the theme switch turn grey until the window is key again. The system does this to every glass surface (`glassEffect`, `.glass`); `GlassSurface` and `GlassMainActionStyle` pass the tint in, and SwiftUI offers no setting to keep it. This is expected, not a bug.

Glamor does not work around it. A solid fill swapped in while the window is inactive would flicker on every focus change and would no longer be the system's glass. The label colour (`G.onAccent`) does not change, so the text stays readable in both states. Reduce Transparency and Increase Contrast use the solid path, which keeps its colours in every window state.

## Known limits in v0.2.0 (not machine-proven)

The release gate (`scripts/release-gate.sh`) runs `scripts/check-window.sh`, which prints these as UNPROVEN or does not reach them. Each row says what was proven instead.

| Not proven | Proven instead |
|---|---|
| Tab order through the 13 gallery controls | Every control is in the accessibility tree with its role, name and enabled state. Keyboard navigation is off on the check Mac, so Tab stops on text fields only |
| Space and Return on buttons (10 controls) | AXPress fires each button's action. Space opens and Escape closes the two menus |
| VoiceOver speech | The accessibility label, role, trait and value of every control, read from the tree, with one name per control |
| The system Reduce Transparency and Increase Contrast settings | A unit test of `GlassPath.choose` for the solid path. A debug palette switch draws the increased-contrast colours in the window, and they are measured |
| Real mouse clicks, including on the button padding | The accessibility frame covers the whole button (at least 24x24, Deploy 68x32) |
| The solid path on macOS 15 and iOS 18 | `#available` checks and unit tests; not run on those systems |
| iOS at run time | iOS is built in CI and in the gate (`generic/platform=iOS`); it is not run in a simulator or measured in a window |
| Indonesian in a window | `LocalisationTests`: every catalog string has `en` and `id` with the same placeholders, the shipped `.lproj` files equal the catalog, and the language falls back to English. The window check reads the English names |

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md). Security: [SECURITY.md](SECURITY.md).

## License

Apache-2.0. See `LICENSE`.
