# Terminal

A terminal session's surface, drawn on `term-bg` in `term-fg` with the six `ansi-*` colors, `mono-large` at 13/18. In Swift, `KomandoTerminalView` (SwiftTerm) themed with these tokens.

**Provide:** the lines, each a string or a list of `[text, style]` runs (red, green, yellow, blue, magenta, cyan, dim, bold, sel), and whether the session has focus.

- Lines fill from the top, as in a real terminal, so a short session leaves no empty band above the first line; once the screen is full, the newest line sits at the bottom and older lines scroll off the top.
- The focused session shows a solid `term-cursor` block; an unfocused one is dimmed with a hollow cursor.
- The command line uses the same colors for the same meanings: green ok, yellow warning, red error.
