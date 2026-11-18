# SectionTitle

The title of a page section, with an optional count beside it and a line under it. In Swift: `SectionTitle("Needs attention", subtitle: "2 findings from komando's doctor")` or `SectionTitle("Hosts", detail: "12")`.

**Provide:** a title in sentence case, and optionally a `detail` (a count, `text3`, tabular) and a `subtitle` (one line, `text2`).

- Put a `LinkButton` or a secondary button at the right end of the same row (`HStack(alignment: .top)`).
- The subtitle reports the state, not a description: "Nothing to fix in komando's setup or inventory".
- **VoiceOver** reads the title as a heading, so a person can jump from section to section.
