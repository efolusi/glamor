# Ecosystem

Three public repos, one brand language:

| Repo | Job |
|---|---|
| [efolusi/design-tokens](https://github.com/efolusi/design-tokens) | Shared token names and values; exports for web and native |
| [efolusi/meridian](https://github.com/efolusi/meridian) | Web: CSS, React, CDN / npm |
| [efolusi/glamor](https://github.com/efolusi/glamor) (this repo) | Native: SwiftUI seeds, HTML previews |

## How they relate

1. **design-tokens** owns shared names and values. Meridian and Glamor consume exports; they should not invent conflicting roles.
2. **Meridian** maps tokens into CSS and React for browsers.
3. **Glamor** maps the same roles into Swift (`K` / `MK`) and keeps HTML cards for visual review.

Glamor still has a full root `tokens.json` (Komando seed). That stays the working native file until design-tokens exports replace it. Meridian still has its own `tokens.json`. Unification is planned, not done.

## Local to Glamor

- `Sources/`
- `components/`
- Product journeys and UX notes under `guidelines/`
- `scripts/`
