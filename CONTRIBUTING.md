# Contributing to Glamor

Glamor is licensed under Apache-2.0. HTML cards under `components/` run through the preview script. Swift under `Sources/` is the native seed.

## Layout

Keep the shallow root. `tokens.json`, `components/`, `assets/`, and `Sources/` are the public contract. Do not reintroduce `design/`.

Authored token file: root `tokens.json`. Keep `Sources/Glamor/macOS/Tokens.swift` and `Sources/Glamor/iOS/Tokens+iOS.swift` in lockstep until `design-tokens` exports land.

Preview cards stay flat: `components/<Name>/preview.html`.

## Local checks

```bash
python3 scripts/design-preview.py --no-open
scripts/check-colors.sh
scripts/check-sizes.sh
scripts/check-motion.sh
scripts/vendor-tokens.sh --check
swift test
```

To see the components in a real Mac window, run `swift run GlamorGallery`: a CardList with a selected row, buttons, the menus and a ProgressBar. With `GLAMOR_GALLERY_SHOTS=/tmp/shots` it saves the window in light and dark and quits. Turn on Full Keyboard Access (System Settings › Keyboard › Keyboard navigation) to Tab through the focus rings.

To look at the components in light and dark, render the snapshot galleries to a folder: `GLAMOR_SNAPSHOT_DIR=/tmp/shots swift test --filter SnapshotTests` on the Mac, and `TEST_RUNNER_GLAMOR_SNAPSHOT_DIR=/tmp/shots xcodebuild test -scheme Glamor -destination 'platform=iOS Simulator,name=iPhone 18 Pro' -only-testing:GlamorTests/SnapshotTestsIOS` for iOS. A normal test run skips them.

`design-preview.py` loads React from jsDelivr (needs network). Output is under `build/` (gitignored).

## Rules

- Neutrals carry the interface; color is for status only.
- One primary action per screen.
- Tokens only: no literal colors or sizes outside `Sources/Glamor`.
- SF Symbols by name unless `guidelines/iconography.md` says otherwise.
- Motion only when it explains a change (`guidelines/overview.md`).
- Prefer shared primitives when generalizing product-specific Page cards.

## Before a PR

- [ ] `python3 scripts/design-preview.py --no-open` succeeds
- [ ] Color / size / motion checks pass for trees you touched
- [ ] Light and dark still work when the change is theme-sensitive
- [ ] No secrets or `.env` files
- [ ] `ARCHITECTURE.md` / `README.md` updated if you moved a public path

## License

By contributing, you agree your contributions are licensed under the Apache License 2.0.
