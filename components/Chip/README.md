# Chip

A capsule choice in a short row. The selected chip is medium `text` on `cardHover` (one weight for every chip, so choosing one never changes its width) with a 1pt `selected-marker` ring (the brand's brown, 3:1 or more on every surface in both themes; at 60% it was 2.7:1, under the 3:1 a selected state needs). Focused, it gets the 2pt `focus` ring, 2pt outside (Memory in the preview). In Swift: `Button(name) { chosen = name }.buttonStyle(ChipStyle(selected: name == chosen))`.

**Provide:** the word and whether it is selected.

- Use chips for a handful of quick choices above a list or a command bar, such as recipe categories or quick commands.
- With more than about eight choices, use a `Picker`.
- Under the pointer an unchosen chip turns `text` on `hover-panel` (no ring, so it never looks chosen); pressed, `pressed`.
