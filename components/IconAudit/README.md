# IconAudit

Proposed: an audit of the SF Symbols the Mac app uses, with each finding drawn today beside the fix, then the full proposed set and its four rules. Nothing here is adopted; the README's Iconography section and the Swift views still use today's symbols. The text version is `iconography.md`.

- **Findings table.** Thirteen rows: what disagrees, the symbols in use with where they appear, and the proposed symbol. Status glyphs keep their status color; tiles are drawn as `IconTile` at 20.
- **The proposed set.** Places, things, status, actions, family tiles and empty states, each meaning with exactly one symbol. Names in `accent` are changes.
- **Rules.** One meaning, one symbol; outline by default, `.fill` only for status and Run; sizes from the scale (`icon-xs` to `icon-2xl`, tiles 20 to 48); colors from the tokens, a family tint only on its own tile.
- **Stand-ins.** Every proposed symbol, the new `square.stack.3d.up`, `play.square.stack` and `waveform.path.ecg` included, comes from **SFSymbol**. Only the retired symbols and outline variants shown under Today, which the app will stop using, are drawn inline in this card, in the bundle's style.
- **Symbols, not lines.** Findings name the symbol and the screen, not a file and line, because the Swift views are being moved to the 4-point scale.
