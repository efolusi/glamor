# TerminalPane

komando's text output on a quiet, terminal-like surface. A bar above the output shows whether it is still running or how it ended. In Swift: `TerminalPane(run: textRun)`, and `OutputText(text:)` for a short block of output inside a page.

**Provide:** the run (its label, running state, result or failure) and a placeholder ("Output appears here.").

- While running, the bar shows a spinner, "Running uptime…" and a ghost **Stop**. On a failed exit it shows "Exit 1 · general error" in `warn` with `exclamationmark.triangle.fill`.
- Output is `mono` in `text`, selectable, scrolls both ways and never wraps.
- Fill and stroke share `radius-8`; the status bar on top is 32 high.
