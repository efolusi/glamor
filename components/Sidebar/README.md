# Sidebar

The Mac sidebar (variant A): the window's ground with a top row for the traffic lights and the Hide button, the caller's header (logo, name, **SidebarSearch**), a scrolling content area of **SidebarItem** rows in folding **SidebarSection** blocks, and a footer pinned under a hairline. In Swift: `Sidebar(width: $width, onHide: { … }) { header } content: { … } footer: { … }`. The four parts are drawn together in the `sidebar-a` scene of the gallery.

**Provide:** the width binding, the Hide action and every word that is the app's own (place titles, counts). The app saves the width (`SizeStore`) and owns the Hide command (⌃⌘S).

- **Ground.** `window`, with 2 between rows and 8 inside each row, so icons line up 20 from the window edge.
- **Content scrolls in a plain stack.** A lazy stack leaves the rows below the fold out of the accessibility tree and the Tab order until they are scrolled to, and a sidebar has about 25 rows. There is no scroll-into-view code: the window check's "Tab to the last row" line tests that the system scrolls a focused row in.
- **The edge** is the one **SplitDivider**: 200 to 320, hides when dragged under the smallest. Variant B (the narrow window) passes `isResizable: false` and a fixed width.
- **VoiceOver** reads one container named "Sidebar" ("Bilah samping").
- **Not built here:** the profile card and the narrow rail.
