# Logo

Komando's one official mark is **K-caret**, chosen on 2026-11-08. This page is its spec; the earlier `>_` mark and the concepts that were not chosen are retired and no longer drawn anywhere in the system.

## K-caret

A K whose stem is the cursor. The cursor bar is the command line's caret, and the chevron after it becomes the K's arms. It keeps the prompt's two parts but arranges them as the app's initial, so it can't be mistaken for another terminal.

### Construction, on a 100-unit square

| Part | Regular, 48 and up | Small, 32 and below |
| --- | --- | --- |
| Square | corner 25 (`radius-tile`, continuous) | same |
| Stem (the cursor) | capsule x 27.5–39.5, y 24–76, 12 wide | capsule x 25–39, y 24.5–75.5, 14 wide |
| Arms | one stroke `M69.5 29.5 L50.5 50 L69.5 70.5`, 10 wide, round caps and join | `M70.5 31 L51.5 50 L70.5 69`, 12 wide |
| Gap between stem and arms | 6 | 6 |

- The glyph sits about 1 unit right of centre, so the open side balances the solid stem.
- The small drawing is for 32, 28, 20 and 16. The heavier strokes keep the K and the caret apart.

### Optical correction

The first drawing (stem and arms both 11, equal heights) was equal on paper but not to the eye: the arms looked heavier and larger than the stem. The numbers above correct that.

- **Diagonals look heavier.** At 47° an 11-wide arm covers 15 to 16 units across, so the arms looked about 40% heavier than the stem. The arms are now 10 and the stem 12, the same ratio a typeface gives a K.
- **Bright shapes look bigger.** The white arms are three times as bright as the blue stem (luminance 0.91 against 0.30), and a bright shape on a dark ground seems to spread. The stem is therefore 0.5 taller than the arms at each end, so the two look the same height.
- **The joint needs room.** The gap between the stem and the arms grows from 5.5 to 6, so the two parts stay apart at 20.
- Don't "fix" these back to equal numbers when redrawing the mark in Swift.

### Color

| Part | Default, both themes | On white | One color |
| --- | --- | --- | --- |
| Square | graphite, `#2E2F35` to `#161619`, top to bottom | `#FFFFFF` with a `border` hairline | none |
| Arms | `#F4F5F7` | `#1C1C1E` (`text`, light) | the one color |
| Cursor | `#6090FF` (`accent`, dark) | `#1659FF` (`accent`, light) | the one color |

- Contrast, from the top of the gradient to the bottom: the cursor is 4.4:1 to 6:1 and the arms 12:1 to 16.5:1, over the 3:1 a graphic needs. On white the cursor is 5.4:1 and the arms 17:1.
- The default is the same in both themes. The white version is for print and the web, never inside the app.
- The tokens are `logo-ground-top`, `logo-ground-bottom`, `logo-ink` and `logo-cursor`.

### Sizes

| Where | Size | Drawing |
| --- | --- | --- |
| Upgrade sheet, alerts | 48 | regular |
| Sidebar, beside "Komando" in `title-m`, `space-8` apart | 28 | small |
| Small places | 20 | small |
| Dock and Finder file | 1024, with the body at 824 on Apple's icon grid | regular at 128 and up, small at 32 and 16 |

- The Dock file adds three things and nothing else: a light from the top (white at 10%), a white hairline at 10% inside the edge, and a soft drop shadow. No glow, and no gradient on the K.

## Do

- Draw the mark with AppLogo in the app, and use the exported icon file everywhere else.
- Keep clear space of at least the stem's width (12 units) on every side.
- Use the small drawing at 32 and below.
- Pair it only with "Komando" in `title-m`, `space-8` to its right.

## Don't

- Recolor the mark, put it on a tint, or add a gradient or a glow to the K.
- Use the K without its square, or the square without the K.
- Use the cursor's blue anywhere else in the mark.
- Rotate, outline or stretch it.

## Files

- The Dock and Finder icon, drawn from this spec at 1024 on Apple's grid, is `komando-app-icon.png` in the Logos group (`/_blob/f049e750db3f2f9bc5016bcb500ebe13`).
- In the app, **AppLogo** (`Apps/macOS/Sources/Komando/DesignSystem/AppLogo.swift`) draws the mark from these numbers, with the small drawing at 32 and below.
