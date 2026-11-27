# SidebarItem

A place in the Mac sidebar (variant A): a 16 symbol, its name and, only where a person acts on it, a count; 32 high. In Swift: `SidebarItem(place: place, selection: $selection, count: count)` for a place of the registry (`Place`, `Sources/Glamor/Places`), or `SidebarItem("Copy", symbol: "doc.on.doc", isSelected: …, count: …) { … }`. It sits in **Sidebar**, inside a folding **SidebarSection**, under a **SidebarSearch**; the four parts are drawn together in the `sidebar-a` scene of the gallery.

**Provide:** the place (title, symbol), whether it is chosen, and for a count the number and the words VoiceOver reads for it (`SidebarCount(2, spoken: "2 transfers running")`: Glamor does not know what is being counted). No shortcut badges: shortcuts live in the Go menu and tooltips.

- **The chosen row** is a `panel` fill with a `border` hairline and the `selected-marker` capsule (4 wide, 60% of the row's height, centred, 4 in from the leading edge), since the fill alone is faint. It is not the `accentSubtle` fill of a list row (**ListRow**): the sidebar keeps the look the mocks showed.
- **Text.** The chosen row is `text`, the others `text2`; one weight, so a row never changes width. Under the pointer a row gets `hover-window`; pressed, `pressed`; focused, the 2pt `focus` ring inside the row's own shape.
- **The count** is `small`, tabular, `accentFg` on an `accentSubtle` pill 20 high, never `accent` as text (copper is 2.72:1 on a card). VoiceOver does not read the pill: it reads the title, then the spoken words as the value. With nothing to act on there is no count, and a failed transfer does not turn it red.
- **VoiceOver:** one name (the title), the selected trait on the chosen row, the symbol hidden. A `help` is the row's tooltip. Without one, the name is the tooltip of the text alone, hidden from VoiceOver: on macOS a tooltip on the row is its help text, and the name would be read twice.
- **Where it lives:** folding blocks are **SidebarSection**, the search capsule **SidebarSearch**, the frame **Sidebar**.
- **Not built here:** the Pro and Soon marks (**Pill**), the profile card and the narrow rail (see **Sidebar**).
