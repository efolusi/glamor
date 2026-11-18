# Glamor

Native design system for Windows, Linux, Mac, Android, iOS, and iPad, by [Efolusi](https://efolusi.com). Swift-first. Compatible with SwiftUI.

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-7A4E2B.svg)](LICENSE)

## What's here

| Path | What it is |
|---|---|
| `tokens.json` | Authored tokens (color, type, space, motion, …) |
| `tokens/` | Platform exports later (`swift/`, `css/`) |
| `assets/` | Logos and brand files |
| `components/` | Flat HTML preview cards (`components/<Name>/`) |
| `guidelines/` | Overview, iconography, logo, journeys, UX review, ecosystem |
| `Sources/DesignSystem/` | SwiftUI desktop seed (`K`) |
| `Sources/DesignSystemMobile/` | iPhone / iPad seed (`MK`) |
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

Seeded from `efolusi/komando-apps` on 2026-11-18: design files lifted to this shallow root; Swift DesignSystem trees kept under `Sources/`. `komando-apps` was not modified.

Next work: turn Komando-specific Page cards into shared primitives, and consume exports from `design-tokens`.

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md). Security: [SECURITY.md](SECURITY.md).

## License

Apache-2.0. See `LICENSE`.
