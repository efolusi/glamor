# DataTable

Rows and columns for query results, cache keys, files, secrets and the audit log. In Swift, the app's `DataGrid` (an `NSTableView`) styled with these tokens.

**Provide:** columns (key, label, alignment, mono, an optional renderer) and rows; optionally the selected row, `dense` for tight lists and `bare` inside panes.

- The header row is 28 high, `small` in `text2` on `panel` with a `border` rule; body rows are 32 high (28 when dense), cells `body` with 12 at the sides, separated by `border` at 70%.
- Right-align numbers and set them, ids and timestamps in mono. A missing value shows NULL in italic `text3`.
- The selected row is `accent` at 10%; hover is `hover-card`, the same as a ListRow in a card.
- **Sort.** A click on a header sorts by that column: numbers by value, text as Finder sorts names, NULL last. A second click turns the order around. The sorted column shows a `chevron.up` or `chevron.down` (8, bold, `text2`) 4 after its name (**PageFiles**). A click anywhere in the header cell sorts, and the selected rows stay selected wherever the sort moves them. How a column sorts is decided once for the whole column: a number column (by its type, or every value a number) sorts by value, exactly for ids past 2^53, with any text after the numbers; any other column sorts as Finder sorts names. VoiceOver reads the header as a button with "Sorted up" or "Sorted down". The card shows a result as it came, sorted up by `customer` and sorted down by `total`; in a debug build `KOMANDO_APP_PAGE=datatable` draws the same three with the app's `DataGrid` (`DataTableGallery`).
- **Column widths.** A column's edge drags from 64 to 640, snapped to 4, with the resize cursor, and the width is remembered per table (`size.columns.<table>`). A double-click on the edge puts the first width back. The edge has no mark of its own, only the cursor, so the card has no picture of it. In the SwiftUI `DataTable` the fixed-width columns drag and the flexible one takes the rest; `DataGrid` (query results, cache values) drags every column.
- **Copy.** ⌘C copies the selected rows, one line each, and the notice above the page says how many ("Copied 3 rows", "Copied 1 row"; a **Banner**, gone after hold-notice), and VoiceOver says "Copied". Motion: the notice arrives with motion-base; Reduce Motion: a motion-fast fade.
- **iPhone and iPad** have no query or cache results, so nothing to sort or resize yet. The iPad's Targets column growing to 480 comes with the iPad work (gap G47).
- **VoiceOver.** A row is one button, selected when it is, with an **Open** action (what a double click or Return does); a column name is a heading, and a sortable one says "Sorted up" or "Sorted down".
