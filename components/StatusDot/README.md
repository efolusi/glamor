# StatusDot

A small filled circle that states health at a glance, always next to a word or a name. In Swift: `StatusDot(color: K.warn, size: 8)`.

**Provide:** a tone and, if needed, a size. Two sizes: 8 everywhere, 6 inside small text (the sidebar status line, pane heads).

- Use `ok` for up or healthy, `warn` for needs attention or partly protected, `danger` for failed or not answering, and `text3` for nothing to report.
- Never let a dot be the only signal: the name, pill or message beside it says the same thing in words, and VoiceOver reads that word, not the color. A severity without a word beside it (a finding) is not a dot: it is a shape, a circle for a problem and a triangle for a warning (**AttentionCard**).
