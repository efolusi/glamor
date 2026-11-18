# TabButton

An open tab in the panel header: a symbol, the title, and a close button that shows when the tab is active, under the pointer, or has keyboard focus (an invisible button must never take focus). In Swift: `TabButton(tab: tab)`. ⌘W closes the active tab.

**Provide:** the tab's symbol and title. The first tab is the place itself and cannot be closed.

- The tab is 28 tall and at most 220 wide, with `radius-8`, a 12 symbol and an 8 close mark in a 16 circle. The active tab is `text` on `subtle` with a 2pt `selected-marker` bar along its bottom edge, `space-8` in from each side (the `subtle` fill alone is 1.1:1), in the same `body` weight as the others, so switching never changes a tab's width.
- Every open tab stays alive in the background, so a query or transcript survives a switch.
