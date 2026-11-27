# Pill

One or two words of status in a capsule: the text in its tone, the fill the same tone at `opacity-pill` (10%) over an opaque `card` ground, so a hovered row, a `subtle` surface or the window never shows through. In Swift: `Pill(text: "Up", color: K.ok)`. A pill is a capsule like every button (GL41).

**Provide:** the word and its tone.

- Use Title Case for states and kinds (Free, Up, Open, Stopped, Job). Use lower case when the word is komando's own (failed).
- Pick the tone by meaning: `ok` for Up, Open, or Free on the Upgrade sheet, `warn` for failed, `danger` for Stopped, and `text2` for a neutral kind. A plan or a feature that is not built yet is not a tinted pill but a **mark** (below).
- Every tone above holds 4.5:1 or more on its 10%-over-card fill in light and dark, wherever the pill sits, so a pill may carry a word by itself. Light: `ok` 4.62, `warn` 4.54, `danger` 4.87, `text2` 6.78. Dark: `ok` 5.56, `warn` 4.74, `danger` 4.61, `text2` 7.62. At 12% `warn` (4.41, light) and `danger` (4.47, dark) fall below 4.5, so the pill uses less tint than an icon tile. Keep `text3` out as a tone: `text2` is the neutral one. `accent` is not a tone: copper as text is 2.72:1 on a card in light; `accentFg` (8.53) or `link` (6.13) carry a word in the brand's colour.

## Marks: Pro and Soon (GL36)

`Pill(mark: .pro)` says a feature is paid; `Pill(mark: .soon)` says it is not built yet. Same size as a pill (20 high, 8 sides, `small`), drawn as an **outline** with no fill, so it reads on the page, a panel and a card.

| Mark | Word (en, id) | Outline | Word colour | VoiceOver (en, id) |
|---|---|---|---|---|
| Pro | Pro, Pro | 1px `accentEdge`, solid | `accentFg` | "Pro, paid feature", "Pro, fitur berbayar" |
| Soon | Soon, Segera | 1px `border`, dashed (4 on, 4 off, as `DashedDivider`) | `text2` | "Soon, not available yet", "Segera, belum tersedia" |

- Colour is never the only sign: the word and the outline (solid or dashed) both differ.
- Place a mark inside a page, next to the thing it names (Settings Sync, Team, AI, Approvals). Never put one on a row of the list of places.
- Both words hold 4.5:1 on the page, a panel, a card, a subtle well and a hovered card in light, dark and both Increase contrast modes; the Pro outline holds 3:1 (`ContrastTests`). The Soon outline is a hairline and takes the control edge with Increase contrast.
- VoiceOver reads one element with the spoken words, not the word on the mark.
