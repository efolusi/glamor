# Security policy

## Supported versions

| Version | Supported |
|---|---|
| `main` | Yes. Fixes land here first |
| The newest tag (`v0.3.1`) | Yes, for security fixes |

Older tags (`v0.3.0`, `v0.2.0`, `v0.1.0`, `v0.0.1`) get no fixes. Each new tag takes the place of the one above.

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
