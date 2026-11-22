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
| `scripts/` | Preview build and color / size / motion checks |

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

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md). Security: [SECURITY.md](SECURITY.md).

## License

Apache-2.0. See `LICENSE`.
