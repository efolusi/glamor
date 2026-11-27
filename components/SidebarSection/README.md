# SidebarSection

A titled block of places that folds, inside the **Sidebar**: a 32 high header in section-label type (upper case by `textCase`, so it follows the language) with a chevron that turns 90° in `motion-fast` (it jumps under Reduce Motion), over its **SidebarItem** rows. In Swift: `SidebarSection("Targets", isExpanded: $open) { … }`, or `SidebarSection("Targets", id: "targets") { … }` to keep the state per window.

**Provide:** the title and one of two ways to hold the state: the caller's binding, or an `id` (unique in its scene; an optional `scope:` names the sidebar when one scene holds two). The `id` form keeps the state in `SceneStorage`, which needs a running scene: a view in a bare `NSHostingView` (the gallery) uses the binding.

- **The header** is a row of its own size and focus ring (`SidebarItemStyle`), so its title starts where the row names start.
- **Folded** rows are not drawn: they leave the accessibility tree and the Tab order.
- **A folded section that holds the chosen place** has lost that row's marker and fill, so pass `containsSelection: true` and `selectedTitle:`: the header shows a `selected-marker` dot and its value reads "collapsed, Host selected".
- **VoiceOver:** the title as written, the header trait, the value "expanded" or "collapsed", the hint "Folds or opens the section"; the chevron and the dot are hidden.
