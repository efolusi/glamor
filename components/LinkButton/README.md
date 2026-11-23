# LinkButton

A quiet text link with a chevron that sits at the right end of a section title, as in "View all 4 ›". In Swift: `LinkButton(title: "View all \(n)") { model.go(.doctor) }`.

**Provide:** a short label that names where it goes.

- Use it to open the full list of something the section shows only part of: View all 4, Audit Log, All 12 jobs. Its label is Sentence case, and a place's name keeps its Title Case (README, Casing).
- The label is `body` in `text2` with an 8 bold chevron 8 after it (`G.Space.labelIcon`) and turns `text` under the pointer. Never use it for an action that changes something.
