# SplitDivider

The one divider every resizable area in the Mac app uses: the sidebar, the agent drawer, side lists and inspectors, the two Files panes and their transfer queue, and the query, cache and terminal splits. In Swift it is `SplitDivider(axis:value:range:default:key:)` in `DesignSystem/SplitDivider.swift`; every area uses it instead of its own `HSplitView` handle.

**Provide:** the axis, the width (or height) it controls, its range and default from the table below, and the settings key it is saved under.

**In Swift:** the table's numbers are `K.Resize` in `Tokens.swift` (one `K.ResizeArea` per area: key, smallest, default, largest), so an area passes `SplitDivider(axis:value:area:room:label:sizes:)`. `sizes: .trailing` is for the pane after the divider (the agent drawer, the transfer queue), `hairline: false` for the sidebar's edge, and `onCollapse` hides the sidebar when a drag ends under 200. Widths are saved in the app's settings as `size.<key>`; `SizeStore` takes its own `UserDefaults` in tests. `K.Resize` also holds the Edit File sheet (520 × 320 smallest, 520 × 480 at first), the Settings window (640 × 600) and `windowMin(sidebar:)`, the window's least width for the live sidebar. In a debug build, `KOMANDO_APP_PAGE=splitdivider` draws this card with the app's own views (`SplitDividerGallery`).

- **Look.** A 1pt `border` hairline, as the line between two panes already is, with a 4 by 24 grip (`radius-full`) in `text3` at its middle, so a person can see that it moves. Between stacked areas the grip lies flat (24 by 4).
- **Hit area.** 4 wide, centred on the hairline (2 each side; on the sidebar's edge it sits wholly on the sidebar's side, under the grip), so the hairline stays 1pt and the pointer still finds it. The cursor is the resize cursor (`NSCursor.resizeLeftRight`, `.resizeUpDown`) over that area.
- **Under the pointer** the grip turns `accent`. **While dragging** the hairline turns `accent` too, and a small mono tip beside it shows the width ("288"). The width snaps to the 4-pt scale.
- **Range.** It stops at its smallest and largest; the tip then says "224 · smallest" or "400 · largest". It never jumps past a pane's content: panes have the smallest widths in the table.
- **Double-click** puts it back to its default. An area with no default (the Files panes, the splits) starts at half the room and goes back to half.
- **The room shrinks.** When the window or page leaves less room than the saved width, the divider gives way; when the room comes back, so does the saved width. Only a drag, a key or a double-click changes what is saved.
- **Keyboard.** It takes focus in Full Keyboard Access (2pt `focus` ring around the grip). ← and → (↑ and ↓ between rows) move it by 4, with ⇧ by 32; Return or Space puts it back to its default. VoiceOver reads it as "List width, 272, adjustable", and its Put Back action puts the default back.
- **Remembered for the whole app** (owner decision 2026-11-14). Each area's width is saved in the app's settings under its own key and comes back in every window and on the next launch. The query, cache and terminal splits are saved per kind of page, not per target.
- **The sidebar's edge** has no hairline, because the sidebar sits on `window` with no fill: only the grip shows, under the pointer or while dragging. Dragged under 200 the sidebar hides, as **Hide Sidebar** (⌃⌘S) does (**AppShell**). Hidden, the window buttons and **Show Sidebar** sit at the left of the panel header.
- **Window size.** With a sidebar from 200 to 320, the window's least width is the live sidebar width plus the 760 page minimum plus the insets, not a fixed 1040.

| Area | Default | Smallest | Largest | Notes |
| --- | --- | --- | --- | --- |
| Sidebar | 256 | 200 | 320 | Under 200 it hides |
| Agent drawer | 400 | 320 | 560 | Whether it is open is remembered too (**PageAgentDrawer**) |
| Recipes list | 272 | 224 | 400 | |
| Jobs log | 400 | 320 | 640 | |
| Audit inspector | 340 | 280 | 480 | |
| Files pane (each) | half | 320 | none | Swap keeps the widths; Show Only folds a pane and keeps the split (**PageFiles**) |
| Files transfers (height) | 160 | 96 | half the page | Folds to its 28 head (**PageFilesTransfers**) |
| Query, Cache keys, Terminal splits | half | 240 | none | Per kind of page; a split keeps its sizes when a pane opens or closes |

- **Every way in.** Drag, double-click (or Return, Space and VoiceOver's Put Back), the keyboard (focus it with Tab in Full Keyboard Access), and for the sidebar View › Hide Sidebar (⌃⌘S) and the sidebar button; for the agent ⌘J.
- **Access.** Named for what it sizes ("Sidebar width", "Agent width", "Pane width", "Transfers height"), with its value and range for VoiceOver; Increase Contrast draws the grip in `text` instead of `text3`.
- **iPhone and iPad.** iPad's Targets list column grows from 360 to 480 with the system's column divider and is remembered (gap G47, built with the iPad work); iPhone has nothing to resize.
- **For beginners:** a grip shows where to drag, a double-click undoes any drag, and the window opens the way it was left.
