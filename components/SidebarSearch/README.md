# SidebarSearch

The capsule at the top of the **Sidebar**: a 32 high pill on `field` with the control edge, a magnifier, the `placeholder` word and the shortcut badge. In Swift: `SidebarSearch(action: { … })`.

**Provide:** the action that opens the app's own command palette (⌘K). The title is the app's word when it has one; the default is "Search" ("Cari"). The shortcut defaults to ⌘K.

- **It is a labelled button, not a text field.** It does not take typing and does not filter the sidebar: the palette and its key binding stay the app's.
- **The label** is `placeholder` at rest and `text2` under the pointer; the focus ring follows the capsule.
- **VoiceOver:** one name (the title); the badge is hidden. The tooltip is the title and the shortcut: "Search (⌘K)".
