# Security policy

## Supported versions

| Version | Supported |
|---|---|
| `main` | Yes. Fixes land here first |
| Tagged releases (when published) | Yes, for security fixes |

No tagged release yet. Until the first tag, only `main` is supported.

## Reporting a vulnerability

Glamor is tokens, HTML previews, and SwiftUI sources. It has no hosted backend, no telemetry, and collects no data. Issues still matter: XSS in a preview card that loads CDN scripts, a malicious asset, or a compromised package once publishing exists.

Report privately via [GitHub private vulnerability reporting](https://github.com/efolusi/glamor/security/advisories/new) or to **security@efolusi.com**. Do not open a public issue. Include the file, a reproduction, and impact. We aim to acknowledge within 72 hours and patch within 14 days (same contact and timing as Meridian).

## Scope

- `components/`, `assets/`, `tokens.json`
- `Sources/Glamor/`
- `scripts/design-preview.py` (loads React from jsDelivr)
- Future publish and release pipelines once they exist

Out of scope: consuming apps, browsers, OS frameworks, or the CDN hosts themselves.

## Repo hygiene

- Do not commit secrets, private keys, or `.env` files.
- Prefer pinned versions (and SRI when practical) for third-party scripts in previews.
- Treat `tokens.json` and token exports as supply-chain surface: a bad edit rethemes every consumer.
