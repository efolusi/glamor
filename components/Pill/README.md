# Pill

One or two words of status in a capsule: the text in its tone, the fill the same tone at `opacity-pill` (10%) over an opaque `card` ground, so a hovered row, a `subtle` surface or the window never shows through. In Swift: `Pill(text: "Up", color: K.ok)`.

**Provide:** the word and its tone.

- Use Title Case for states and kinds (Free, Coming, Up, Open, Stopped, Job). Use lower case when the word is komando's own (failed).
- Pick the tone by meaning: `ok` for Up, Open, or Free on the Upgrade sheet, `warn` for failed, `danger` for Stopped, and `text2` for a neutral kind or Coming (a feature that is not built yet). No pill shows a plan, a trial or a lock anywhere else: the apps are free.
- Every tone above holds 4.6:1 or more on its 10%-over-card fill in both themes, wherever the pill sits, so a pill may carry a word by itself. Light: `ok` 4.66, `warn` 4.70, `danger` 4.68, `accent` 4.63, `text2` 6.90. Dark: `ok` 6.12, `warn` 6.58, `danger` 4.64, `accent` 4.65, `text2` 6.68. At 12% `accent` and `danger` fell to 4.50, so the pill uses less tint than an icon tile. Never use `text3` as a tone: it falls to 4.44:1 (light) and 4.33:1 (dark).
