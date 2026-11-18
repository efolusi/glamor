# Tokens

Root `../tokens.json` is the authored source for Glamor.

Platform exports belong here when generated:

| Path | Consumer |
|---|---|
| `swift/` | `Sources/DesignSystem`, `Sources/DesignSystemMobile` |
| `css/` | Previews or any web surface that mirrors Glamor |

Until exports exist, Swift values live in `Sources/**/Tokens.swift`. Keep those files aligned with `tokens.json`. Shared cross-repo work moves to [design-tokens](https://github.com/efolusi/design-tokens).
