# ActivityRow

A row in a list of things that happened or are happening, such as jobs, forwards and secrets, with a menu of actions. In Swift: `ActivityRow(symbol:tint:title:detail:meta:) { Button("Logs") {…}; Button("Stop") {…} }`.

**Provide:** a symbol and tint, a title, an optional detail in mono (the command or rule), meta parts joined with " · ", and the menu's actions.

- Rows are 64 high with 16 at the sides. Put them in one `.card()` with 1pt `border` lines between them.
- Put actions in the `ellipsis` menu, not in buttons on the row.
