# Segmented

A 28 track on `subtle` with 24 segments; the chosen one is raised (`card`, a hairline, `shadow-control`), the others turn `text` under the pointer, and every segment keeps one weight so choosing never changes its width. In Swift: `SegmentedControl(items:selection:)`, with `fill: true` for equal segments across a card's list head (Containers · Images). The profile menu's Appearance keeps the system `Picker(…).pickerStyle(.segmented)`, as macOS draws it in a popover.

**Provide:** two to four short labels and the selection.

- Use it to switch views of the same thing (Grid / List, Query / Table / Structure) or a mode (Ask / Act).
