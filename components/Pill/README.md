# Pill

One or two words of status in a capsule: the text in its tone, the fill the same tone at `opacity-pill` (10%) over an opaque `card` ground, so a hovered row, a `subtle` surface or the window never shows through. In Swift: `Pill(text: "Up", color: K.ok)`.

**Provide:** the word and its tone.

- Use Title Case for states and kinds (Free, Coming, Up, Open, Stopped, Job). Use lower case when the word is komando's own (failed).
- Pick the tone by meaning: `ok` for Up, Open, or Free on the Upgrade sheet, `warn` for failed, `danger` for Stopped, and `text2` for a neutral kind or Coming (a feature that is not built yet). No pill shows a plan, a trial or a lock anywhere else: the apps are free.
- Every tone above holds 4.5:1 or more on its 10%-over-card fill in light and dark, wherever the pill sits, so a pill may carry a word by itself. Light: `ok` 4.62, `warn` 4.54, `danger` 4.87, `text2` 6.78. Dark: `ok` 5.56, `warn` 4.74, `danger` 4.61, `text2` 7.62. At 12% `warn` (4.41, light) and `danger` (4.47, dark) fall below 4.5, so the pill uses less tint than an icon tile. Keep `text3` out as a tone: `text2` is the neutral one. `accent` is not a tone: copper as text is 2.72:1 on a card in light; `accentFg` (8.53) or `link` (6.13) carry a word in the brand's colour.
