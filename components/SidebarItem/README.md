# SidebarItem

A place in the sidebar: a 16 symbol, its name and a count, 32 high. The selected row is a `panel` fill with a `border` hairline and the `selected-marker` capsule (4 wide, 60% of the row's height, centred, 4 in from the leading edge), since the fill alone is faint. Focused, it gets the 2pt `focus` ring, 2pt outside. In Swift: `SidebarItem(place: .hosts)`.

**Provide:** the place's symbol, name and count (`text3`, tabular). No shortcut badges: shortcuts live in the Go menu and tooltips.

- **Files counts transfers, not things.** Its count is the number of transfers running in the app-wide queue, in `caption` `accent` at weight 500, with the tooltip "2 transfers running". With none running it shows no count. A failed transfer does not turn it red: the queue on **PageFiles** says what failed.
- Six places, in order: Home, Hosts, Connections, Files, Port Forwarding, Recipes (⌘1 to ⌘6, owner decision 2026-11-14). Jobs, Keychain and Audit Log sit under **More**, a `text3` disclosure row that starts closed and opens when one of them is chosen.
- The sidebar sits on `window` with 2 between rows and 8 inside each row, so icons line up 20 from the window edge.
- Selected rows are `text` with a semibold symbol, other rows `text2`; the words keep one weight, so a row never changes width. Under the pointer a row gets `hover-window` (1.06:1 in both themes, quieter than the chosen place); pressed, `pressed`.
- Six places, never a seventh: a new feature goes under More, into ⌘K, or into the page it belongs to.
