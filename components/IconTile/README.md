# IconTile

A rounded square that holds a symbol on its own tint at 12%. It is the face of every target, menu row, activity and form. In Swift: `IconTile(symbol: family.symbol, tint: family.tint, size: 38)`; `FamilyBadge(family:)` is the 40pt shortcut.

**Provide:** an SF Symbol name, a tint (a family tint for targets, `accent` for new items, `text2` for places) and a size.

- Five sizes, each with a fixed glyph: `tile-20` (12) in chips, `tile-28` (16) in palette rows, menus, running cards and the Upgrade sheet's features, `tile-32` (16) in activity rows and two-line rows, `tile-40` (20) on target cards and family badges, `tile-48` (24) in form, sheet and detail headers.
- The glyph is `.medium`; the corner is `radius-tile`, a quarter of the side, continuous.
- There is one look only: the glyph in its tint on the tint at 12% (`opacity-tint`). The filled tile (a white glyph on a gradient) is gone, because the design has no decorative gradients.
- Don't put letters or numbers in a tile, or tint it with a color outside the tokens.
