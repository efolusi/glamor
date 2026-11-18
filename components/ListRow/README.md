# ListRow

Every row a person picks from: a table in the schema, a recipe, a collection, a cache key, a service, a host in its card. One spec, like a macOS source list, so no list feels cramped. In Swift: `.buttonStyle(.row(selected:height:))`, `.rowHighlight(selected:hover:)` for a row that takes its own clicks, `SideListStack { }`, `ListSectionLabel("Saved")` and `ListRow` for a row in a **CardList**. The numbers are `K.Row`.

**Provide:** what the row is (a 16 symbol when the list mixes kinds, the name, maybe a count or one line of help) and whether it is selected.

- **The highlight never touches the edge.** In a side list it sits 8 in from the panel's edge (`K.Row.listInset`); in a card, 4 in on every side (`K.Row.cardInset`), so its 8 corners follow the card's 12.
- **The text has room inside it.** 12 from the highlight's edge (`K.Row.padding`): 20 from a side list's edge, the same as the sidebar's places, and 16 from a card's edge, where its hairlines start.
- **Rows breathe.** 2 between two rows of a side list (`K.Row.gap`); in a card the 4 insets and the hairline keep 8 between two highlights.
- **Heights.** 32 for one line, 52 for a name over one line of help (`K.Row.oneLine`, `K.Row.twoLine`). A row in a card is 40 in all: a 32 highlight and 4 around it.
- **States.** Under the pointer `hover-card` in a card and `hover-panel` in a side list (K.Hover; 1.10 to 1.12:1 in both themes); pressed, `pressed`; selected, `accent` at 10% with the 2-pt `selected-marker` at its leading edge; focused, the 2-pt `focus` ring on the highlight's own shape (radius 8), so no card clip or next row cuts it. Secondary text on a selected row moves up to `text2`.
- **The text never moves.** No state changes the padding or the weight.
- **Increase Contrast.** `text3` turns `text2`, hairlines turn `controlEdge`; the marker, not the fill, says which row is chosen.
- **Group labels** (`ListSectionLabel`) start where the rows' text starts: 12 inside the list's 8.
- **The sidebar** keeps its own look (**SidebarItem**): its highlight is 12 in, in line with the Search field and the profile row, and its text sits at 20 like every side list.
- **Tables** (**DataTable**) are a grid, not a list: full-width rows, 12 inside each cell.
- **iPhone and iPad** use the system's lists (inset grouped, the iPad sidebar), which already give each row its inset, height and selection.
