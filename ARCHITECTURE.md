# Architecture

How Glamor's pieces fit. Read this before moving or renaming public paths.

## Layout

```
glamor/
├── tokens.json · design-system.json
├── tokens/                 # export home (swift/, css/ later)
├── assets/ · components/   # brand files; flat HTML preview cards
├── guidelines/
├── Sources/DesignSystem/
├── Sources/DesignSystemMobile/
├── scripts/                # design-preview.py, check-*.sh
├── Tests/ · build/         # build/ is gitignored preview out
└── README, ARCHITECTURE, CONTRIBUTING, SECURITY, …
```

## Rules

1. **Root paths are a contract.** `tokens.json`, `assets/`, `components/`, and `Sources/` stay at the repo root. Do not put them under `design/` again.
2. **Keep it shallow.** One folder per preview card: `components/<Name>/`. Scripts reach the root with one `../`.
3. **Swift is runtime; HTML is preview.** `Sources/` implements the system. `components/` is the catalog for `scripts/design-preview.py`.

## Authored vs generated

| Path | Who writes it | Notes |
|---|---|---|
| `tokens.json`, `Sources/`, `components/`, `guidelines/` | Authors | Commit these |
| `build/design-preview/` | `scripts/design-preview.py` | Local only, gitignored |
| `tokens/swift/`, `tokens/css/` | Future generators | Not present yet |

Do not edit files under `build/`. Regenerate them.

## Invariants

1. Preview reads `tokens.json`, `design-system.json`, `assets/`, and `components/` from the repo root.
2. Until `design-tokens` exports feed this repo, keep `tokens.json` aligned with `Sources/**/Tokens.swift` by hand.
3. Shared token names belong in [design-tokens](https://github.com/efolusi/design-tokens). Web lives in [Meridian](https://github.com/efolusi/meridian). See [guidelines/ecosystem.md](guidelines/ecosystem.md).

## Check locally

```bash
python3 scripts/design-preview.py --no-open
```

Open `build/design-preview/index.html`. Blank cards usually mean the jsDelivr React scripts failed to load.
