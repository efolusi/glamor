# Sheet

A sheet over the window for a short task: New Forward, New Secret, Upgrade. `sheet-width` (520), `radius-16`, 24 inside, 20 between the head, the body and the actions; the window behind is covered by `scrim`.

**Provide:** an optional symbol and tint (a 48 tile), the title in `title-l`, a one-line subtitle, the fields, and the actions: Cancel (secondary) and the action (primary), both 32, on the right.

- Return runs the primary action, esc cancels; so a sheet's fields are single-line (see **TextField**). The one exception is New Recipe's Command, where Return adds a line and ⌘Return saves.
- Every sheet opens with the cursor in its first field (on an Edit sheet, Name).
- **Fixed or resizable.** A form sheet is `sheet-width` wide and as tall as its body. A sheet that shows something long a person reads or edits (a file, a log) is resizable by its edges: it opens at its first size, never gets smaller than its smallest, and grows to the screen; its body fills the room and does its own scrolling (`SheetLayout(resize:)`; Edit File opens at 520 by 480 and is never under 520 by 320, **PageEditFile**).
- A body taller than the window scrolls; the head and the actions stay in view. What a save said (komando's error, as a danger **Banner**) sits 20 above the actions, outside that scroll, so it is never hidden below the fold (**PageEditTarget**).

- Motion: none of our own. The system's sheet motion. A result **Banner** inside it arrives as Banner draws it.
