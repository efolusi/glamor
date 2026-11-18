# MenuRow

A row in a popover menu: 52 high: a 32 tile, a title, a line of help and a shortcut. Under the pointer the row turns `hover-panel`; pressed, `pressed`, on the **ListRow** spec (12 inside, radius 8). No Mac screen draws this menu now; a row like it uses `.buttonStyle(.row(height: K.Row.twoLine))`.

**Provide:** a symbol and tint, a Title Case title, one help line saying what it is ("A server you reach over SSH"), and the shortcut.

- The popover is `menu-width` (320) wide with 8 padding, and opens toward the trailing edge from the button that shows it.
