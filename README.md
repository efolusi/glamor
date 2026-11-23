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
| `Sources/Glamor/` | SwiftUI tokens (`G`) and components: `macOS/`, `iOS/`, `Text/`, `Decor/` (backdrops), `Haptics/` |
| `scripts/` | Preview build, color / size / motion checks, and the window checks (`check-window.sh`) |

## Principles

- Neutrals carry the interface; color is for status only.
- One primary action per screen.
- Tokens only: no literal colors or sizes in product views.
- SF Symbols by name; no custom icon set.
- Motion only when it explains a change.
- Same words and status meanings on every platform.

## Ecosystem

| Repo | Role |
|---|---|
| [design-tokens](https://github.com/efolusi/design-tokens) | Shared tokens |
| [Meridian](https://github.com/efolusi/meridian) | Web (React, CSS, CDN) |
| **Glamor** (this repo) | Native / SwiftUI |

See [guidelines/ecosystem.md](guidelines/ecosystem.md) and [ARCHITECTURE.md](ARCHITECTURE.md).

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

Light and dark are the gallery's own `--appearance` argument. The script never changes a system setting. It
cannot set SwiftUI's `accessibilityReduceTransparency` or `colorSchemeContrast` (read-only environment values), so
the solid (non-glass) path is not drawn in a window; the Increase contrast colours are. Tab reaches buttons only
with System Settings › Keyboard › Keyboard navigation on; with it off the Tab order and Space/Return on buttons
print `UNPROVEN`. Exit 0: nothing failed. Exit 1: a check failed. Exit 2: it could not run. Screenshots and tables
go to `GLAMOR_WINDOW_OUT` (default `.build/window-check`). Run it with the Mac idle: one gallery window opens per scenario.

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md). Security: [SECURITY.md](SECURITY.md).

## License

Apache-2.0. See `LICENSE`.
