Glamor is the native design system for Efolusi's apps on Mac, iPhone and iPad, built in SwiftUI. Its colours and sizes come from `efolusi/design-tokens`, the same tokens Meridian uses on the web, so both share one brand. The previews here redraw the SwiftUI views in HTML; the Swift names in each guideline are the API to use.

komando's editions, screens and platform notes live in efolusi/komando-apps design/README.md.

## Layout rules

Every screen follows these rules; a design that breaks one needs a reason written next to it.

- **A few places, and no more.** The sidebar holds a small, fixed set of places, each with its own ⌘ number. Everything else lives under **More**, in ⌘K, or inside the page it belongs to.
- **Areas resize with one divider.** Sidebars, drawers, side lists, inspectors and splits are resized with **SplitDivider**: a visible grip, a double-click to reset, widths on the 4-pt scale and remembered for the whole app. Each area has a default, smallest and largest width.
- **One primary button per view.** It sits at the right of the panel header and is named for what it does or makes ("Add", "New Project"). Everything else is secondary or ghost.
- **One way in.** One search (⌘K). One way to open a thing, never two. One create button that opens one chooser for every kind.
- **Advanced features hide until asked.** They live in ⋯ menus and shortcuts, not in toolbars.
- **A fact appears once per view.** An address is in the subtitle or in a card, not both.
- **Lists before cards.** Inventories are one-line lists that keep long names whole, filtered by a chip row. Cards are for the few things that need attention or are running.
- **Plain words first.** Say what is wrong and offer one action, never a raw check name or a command to copy. Commands appear where a person ran them.
- **No decoration.** No dates in headers, no counts repeated from the sidebar, no shortcut badges on rows (shortcuts live in menus and tooltips), no gradients. One gradient stays, for a reason: the app logo's ground. Everything else, the avatar and the skeleton included, is one solid fill.

## Content fundamentals

**Names keep their own case.** Write a product's name exactly as its brand writes it, even at the start of a sentence, and never add a plan name to it.

**Plain, short and specific.** Say what happened and what to do next. Name the thing and the number, and skip adjectives and exclamation marks.

- Empty: "Nothing is running." · "No activity yet." · "Everything looks fine."
- Failure: "The server did not answer", followed by the error and its hint, then **Try Again**.
- Help: "Read the inventory again (⌘R)" · "Protected: changes need your confirmation"
- Selling: "Every feature on every server. One key, no account." · "Browsing and connection tests stay free."

**Casing.**

| Where | Case | Real examples |
| --- | --- | --- |
| Buttons and menu items | Title Case (macOS) | Fix · Protect · New Forward · Open Terminal |
| Places in the sidebar | Title Case nouns | Home · Port Forwarding · Audit Log |
| Tabs and segmented choices | Title Case, never starting with the product's name | SSH Agent · Saved Key · Password · SOCKS Proxy |
| Section titles | Sentence case | Needs attention · Running now · Recent activity |
| Form, checkbox and toggle labels | Sentence case | Connection name · Allow changes · Reach through a server or VPN |
| Links (LinkButton) | Sentence case, as part of the sentence they finish; a place's name keeps its Title Case | View all 4 · Forgot your password · Continue without an account · Audit Log |
| Tooltips | Sentence case, also on an icon button | New conversation · Sign in again; changes nothing |
| Status pills | Sentence case, first word capital | Done · Failed · Blocked · Up · Changes the server · Read-only |
| Section labels in panels | Capitals, `section-label` | IN SCOPE · PERMISSIONS |
| Commands, flags, addresses | As typed, in `mono` | `--allow-dangerous` · `deploy@10.0.0.4` |

**Weight.** Three weights, each with one job, so a glance tells a title from a name from text:

| Weight | Used for | Real examples |
| --- | --- | --- |
| Semibold (600) | Titles and headings only | page, sheet, section and empty-state titles, a panel's heading, SECTION LABELS, the primary button |
| Medium (500) | The name of a thing, a label you act on, a message's headline | host and connection names in lists, a job's or recipe's name, form labels, chips, secondary buttons, a finding's sentence, a banner's title |
| Regular (400) | Everything else | descriptions, values, addresses, help, meta, ghost buttons, menu items |

- **Choosing never changes weight.** A selected place, tab, chip, pane, tree row or list row keeps its weight; the fill, the underline or `text` color marks it. A bolder chosen item grows wider and pushes its neighbours.
- **No bold inside a sentence** for emphasis; put the name in mono or the word in its tone instead.

**Punctuation.** End a command that opens a dialog with an ellipsis ("Upgrade…", "Settings…", "Choose a Folder…"), and a status that is still in progress too ("Running uptime…", "Checking the server…"). Join metadata with a middle dot: "Local · on this Mac", "PostgreSQL · db.internal · via bastion". Write counts as fractions in `mono-small` ("3/5") and dates as relative times ("2 days ago", "since 09:14").

**Name the device.** Say "this iPad" on iPad, "this iPhone" on iPhone and "this Mac" on the Mac, from the device the app runs on, never "this phone" on an iPad; say "this device" only where the device does not matter.

**Person.** Address the person as *you* only when it matters ("You confirm every protected change."). Refer to the app or tool by name ("Backup will run again tonight."), never as "we". Use no emoji, ever.

**Safety copy is concrete.** A destructive confirmation names the risk in its title ("This target is protected", "This command looks destructive", "This changes data"), puts the exact command or flag in the message, and labels the button with what happens: **Run Anyway**, **Allow Once**, **Allow Writes**, never "OK".

## Visual foundations

### Layout

- The window is `window`. The sidebar (`sidebar-width`, 256) sits directly on it with no fill of its own. The content is a floating `panel` inset `window-inset` (8) on top, right and bottom, with `radius-12`, a `border` hairline and `shadow-panel`.
- The panel opens with a header (`header-height`, 52): the page title in `title-m`, or the open tabs when there is more than one. A 1pt `border` line separates it from the page.
- A page scrolls inside the panel with `space-32` horizontal and `space-24` vertical padding, `space-24` between sections, and content capped at `page-max`, centred.
- Separate the sections of a page with **DashedDivider** (`border`, 4 on, 4 off), not with headers in boxes or background bands.
- Put cards in grids with `space-16` gaps: two flexible columns for attention items, adaptive columns of at least 248 for running items.

### Color

- Neutrals carry the interface. Write text in `text`, `text2` or `text3` only, on `window`, `panel`, `card`, `subtle` or `cardHover`.
- Use status colors with one meaning each: `ok` means healthy or done, `warn` needs attention or is protected, `danger` failed or stopped, and `accent` is focus, the prompt and new items. Every status color appears next to a word or an icon, never alone.
- Tint by opacity, never with a new hex: icon tiles use their color at `opacity-tint` (12%), pills at `opacity-pill` (10%), banners at `opacity-banner` (10%), and the attention card at `opacity-attention` (5%) with a stroke at `opacity-attention-stroke` (55%).
- Give each target family its tint (`tint-servers`, `tint-databases`…) and use it only on that family's icon tile. A family tint never colours text.
- **Contrast.** Every text color, `text3` and the four status colors included, meets 4.5:1 on every surface in both themes, including inside its own pill. Family tints meet 3:1 as glyphs on their tiles, and the focus ring meets 3:1 on panel and field. Each token's note gives its numbers. Check a new color against the same grounds before adding it, and give it its own token instead of making a token lighter.
- **The light theme's orange is a burnt orange** (`warn`, `#b24a00`): bright enough to read as a warning, dark enough to carry text. Don't swap in the system orange, which is under 2.5:1 on white.

### Type

- Use SF Pro and SF Mono through `Font.system`. Ship no font files, because the system provides them.
- Use six sizes and nothing else: 11 (`small`, `section-label`, `mono-s`), 12 (`caption`, `mono`), 13 (`body`, `body-medium`, `body-strong`, `mono-l`), 15 (`title-s`), 17 (`title-m`, `input-l`) and 20 (`title-l`). No half sizes and, on the Mac, no system text styles.
- **iPhone and iPad use iOS text styles** (owner decision 2026-11-12), so every size grows with Dynamic Type. At the default text size they land on the same six sizes: `ios-title` 20 (`.title3` semibold, `G.title`), `ios-headline` 17 (`.headline`), `ios-body` 15 (`.subheadline`), `ios-small` 13 (`.footnote`), `ios-caption` 12 (`.caption`) and `ios-tiny` 11 (`.caption2`); mono is the same style with `design: .monospaced`. Line heights are the system's. The Mac keeps fixed sizes, because macOS text styles change with its own settings.
- Emphasise with weight before size. A selected sidebar row or tab changes from regular to semibold and from `text2` to `text`, with no other change.
- Set anything a command line prints or reads in `mono`: commands, output, addresses, ratios and counts. Use `.monospacedDigit()` for counts in proportional text.

### Sizes

Everything sits on a 4-point grid. Every height, padding, gap, margin and radius is one of the tokens; 2 is only for the gap between stacked lines of text. Controls in one row always share one height. Controls are 24, 28, 32 or 40 high; the one exception is iPhone and iPad, where anything you tap is at least 44 (`touch-44`, Apple's minimum; owner decision 2026-11-12). The Mac keeps the strict scale. Fixed-height things set their height and centre their content; they never get their height from padding.

| Thing | Height | Padding (sides) | Radius | Type |
| --- | --- | --- | --- | --- |
| Button, standard (primary, secondary, ghost) | 32 | 12 (ghost 8) | 8 | `body-strong` / `body-medium` / `body` |
| Button, compact (toolbars, cards, table rows) | 28 | 12 (ghost 8) | 6 | same |
| Icon-only button | 28, or 24 in rows | square | 6 | `icon-md`, `icon-sm` |
| Text field, sidebar search | 32 | 12 | 8 | `body`, `mono-l` |
| Compact field (toolbars, side panels) | 28 | 8 | 6 | `body` |
| Search bar, command bar line | 40 | 12 | 12 | `body`, `mono-l` |
| Chip, segmented control | 28 | 12 (segment 8) | full, 8 outer / 6 thumb | `caption` |
| Pill | 20 | 8 | full | `small` |
| Shortcut badge | 16 | 4 | 4 | `small` |
| Sidebar place, list row, table row, menu item | 32 | 8 (table cells 12) | 8 | `body` |
| Table header | 28 | 12 | – | `small` |
| Palette row, info row, inventory row, group row | 40 | 8 to 16 | 8 | `body` |
| Two-line row (menu with help, target in a list) | 52 | 12 | 8 | `body-strong` + `caption` |
| Activity line (Home's Recent activity, `k-actline`) | 40, one line, `k-rule` between | 0, `space-12` gaps | – | `icon-md` + `body` + `caption` (who · when) |
| Three-line row (**ActivityRow**: jobs, forwards) | 64 | 16 | – | `body-strong` + `mono` + `caption` |
| Panel header / tab inside it | 52 / 28 | 24 / 8 | – / 8 | `title-m` / `body` |
| Toolbar in a tab / pane head / status bar | 44 / 28 / 28 | 16 / 12 / 12 | – | `body` / `caption` / `caption` |
| Card, attention card, banner | content | 16 (banner 12) | 12 (banner 8) | – |
| Sheet / palette / popover | content | 24 / 0 / 8 | 16 / 16 / 12 | – |
| Tile / dot / bar | 20, 28, 32, 40, 48 / 6, 8 / 4 | – | 25% / full / full | – |

- **Sidebar:** content inset 12; places are 32 high with 8 inside, so their icons line up on x = 20, and the logo row uses the same 20.
- **Page:** 24 top and bottom, 32 at the sides, 24 between sections, 16 between cards, 16 inside cards.
- **Between controls:** 8 between any two controls side by side, icon-only buttons included (the agent and refresh in the header too), 16 before a header's primary. 8 between a glyph and its label, 12 between a tile and its text.
- **A control inside another:** a button or × inside a field, a tab or a bar sits 8 from that edge, the same as the text on the other side, never 4.
- **Menus:** rows 2 apart; a separator is a hairline with 4 above and below, inset 8; a long item ends in an ellipsis inside the menu.
- **Forms:** 8 from a label to its field and from the field to its help, 16 between fields.
- These were measured across every card (2026-11-09); check new screens the same way rather than by eye.
- **Gaps:** 4 between a label and its chevron, 8 between an icon and its label and between buttons, 12 between a tile and its text, 16 between fields in a form.

### Shape, borders and depth

- Every container is a rounded rectangle with `.continuous` corners, its radius chosen by its height: `radius-6` for compact controls (28), `radius-8` for standard controls (32) and rows, `radius-12` for cards, the panel and popovers, `radius-16` for the palette, sheets and the composer. Pills, dots and bars are capsules. **Shapes, one rule.** A **capsule** holds only words or shows an amount: Pills, filter Chips, ProgressBars, the Switch. A **circle** is a person (the avatar), a status dot, or a spinner. **Everything else is a rounded rectangle**, its corner set by its height: buttons (icon-only ones too, like ⋯, × on a tab, send and run), fields, icon tiles and the agent's mark, the composer's scope chips (they hold a tile), cards, menus, sheets. SF Symbols that are drawn as circles (`checkmark.circle.fill`, `xmark.circle.fill`) stay only as status glyphs.
- Define a card with a 1pt `border` hairline (`strokeBorder`, drawn inside) on `card`. At rest a card has no shadow. A clickable **HoverCard** switches to `cardHover` and gains `shadow-hover` under the pointer.
- `border` is decorative only. The outline of a thing that is a control (the off Switch track, an unchecked Checkbox, a text field) is `controlEdge`, which holds 3:1 on every surface in both themes.
- A Pill draws its tint on an opaque ground: the status color at `opacity-pill` (10%) over `card`, so a hover or selected row behind it never shows through. The same goes for the Protected capsule on a target. Its text, in the status color, holds 4.6:1 or more on that ground in both themes: in light ok 4.66, warn 4.70, danger 4.68, accent 4.63; in dark ok 6.12, warn 6.58, danger 4.64, accent 4.65. At 12% accent and danger sat at 4.50, with no margin. With Increase Contrast the tint is 16% and the status colors take their increased pair (see States), so the text still holds 4.61:1 or more.
- The avatar is one solid fill, `avatar` (#247A43), the same in both themes (it does not follow the theme), so its white initial holds 5.33:1 everywhere. Icon tiles are always the 12% tint; there is no filled tile.
- Keep shadows faint and functional: four shadows, all black, never colored. `shadow-control` (G.Shadow.control) on the primary and secondary buttons, a MenuPicker, the chosen segment and the split tip; `shadow-hover` (G.Shadow.hover) on a HoverCard under the pointer and nowhere else; `shadow-panel` (G.Shadow.panel) on the floating content panel; `shadow-palette` (G.Shadow.palette) on the ⌘K palette. Cards, rows, banners, pills, the agent's composer and the whole iPhone and iPad app have none. Draw them only as `.shadow(G.Shadow.x)` (`scripts/check-colors.sh`).

### States

- Hover has three levels, each the same strength wherever it appears, and it comes in and goes at once (no motion).
  - **Items** (list, table and side-list rows, menu and palette rows, chips, the ⋯, ghost buttons, sidebar places, panel-header tabs): a fill chosen by the ground under it, `hover-card` (G.Hover.onCard), `hover-panel` (G.Hover.onPanel) or `hover-window` (G.Hover.onWindow); a panel-header tab takes `hover-tab` (G.Hover.onTab), quieter than the active tab's `subtle`. All sit at about 1.06 to 1.12:1 in both themes, so text3 keeps 4.5:1 on it. Words in `text2` may turn `text`.
  - **Raised controls** (secondary button, MenuPicker, HoverCard, the profile row, the sidebar Search): `card` to `cardHover`. Only a HoverCard also gains `shadow-hover`.
  - **Primary**: `accent` to `accentHover`, an opaque mix, so the ground never shows through.
  - Never use `accent`, a status color or a family tint as a hover fill. A destructive action (Remove…) hovers like its level; only its word is `danger`.
- Pressed: one step past hover. Items and raised controls take `pressed` (G.Hover.pressed); the primary button takes `accentPressed`. Nothing fades or dims on press. text3 keeps 4.5:1 on `pressed` too.
- Disabled: the primary button at `opacity-disabled` with no shadow; secondary text in `text3`.
- Focus, fields: an input's border becomes `accent` at `opacity-ring`, 2pt (`focus-ring`). Never add a glow.
- Focus, everything else you can press (buttons, chips, sidebar places, tabs, list rows, cards, switches): a `line-strong` (2pt) line in `focus` with a `focus-offset` (2pt) gap, one recipe on the Mac and in these cards. Around a control: `RoundedRectangle(cornerRadius: r + 4).strokeBorder(G.focus, lineWidth: 2).padding(-4)`, so the line sits 2 to 4pt outside the shape and never touches its fill. A selectable row (**ListRow**) draws it on its own highlight, inside: `RoundedRectangle(cornerRadius: G.Row.radius).strokeBorder(G.focus, lineWidth: 2)`, so a card's clip or the next row never cuts it. 4.8:1 or more against what surrounds it in both themes (WCAG 2.4.7 and 2.4.13). Every custom `ButtonStyle` reads `@Environment(\.isFocused)` to draw it; a control that hides until hover (a tab's ×) shows while it has focus (UX audit P1-9, P1-10).
- Selected: the fill still says "this one" (a `panel` fill with a `border` hairline in the sidebar; `subtle` on a tab; `accent` at 10% on a list row), but a fill is only 1.04 to 1.11:1, so every selected item also has a `selected-marker` (accent) mark of 3:1 or more: a 2pt bar, 16 high, at the leading edge of a sidebar place or list row (the first cell of a table row); a 2pt bar under the active panel-header tab; a 1pt ring around a selected chip (4.4:1 or more against the fill it sits on, both themes). Underline tabs keep their 2pt `text` rule (UX audit P1-8).
- Increase Contrast (macOS and iOS): `border` becomes `controlEdge` (3:1), `text3` becomes `text2`, the hover and pressed fills take their `increased` pair (about 1.2:1), and pill and tile tints go from 10 to 16% (`opacity-increased`). At 16% the normal status colors fall to 4.2 to 4.3:1 inside their pill, so `accent`, `ok`, `warn` and `danger` take their `increased` pair from tokens.json (darker in light, lighter in dark) and hold 4.61:1 or more inside a 16% pill in both themes. Read it with `colorSchemeContrast` / `accessibilityContrast` (UX audit P2-3, P2-8).

### Motion

Motion only explains a change (owner decision 2026-11-15). It answers one of three questions: *what changed*, *where did it go*, or *is it still working*. If it answers none, nothing moves. The tokens are `motion-*`, `ease-*`, `delay-*`, `hold-*` and `guard-*` in tokens.json, and `G.Motion` in `DesignSystem/Motion.swift`. **MotionSpec** shows each one live, with a Reduce Motion switch.

1. **Fast first.** The app never waits for an animation. Every animation can be interrupted, and a keypress always acts at once.
2. **What you do often stays still.** ⌘K, switching places and tabs, moving through a list with the keyboard, typing in a terminal, opening a menu, selection: all instant.
3. **Short and calm.** Feedback takes `motion-fast` (120 ms). Something appearing or leaving takes `motion-base` (200 ms). A panel takes `motion-slow` (250 ms). Nothing is longer. Springs never bounce: no scale-up pop, no zoom, no depth.
4. **Status changes at once.** A status color, a status word, an exit code and a count are true on the first frame and are never faded or delayed. Only the status *symbol* may change with a `motion-fast` Magic Replace (`.contentTransition(.symbolEffect(.replace))`), because the new state is already visible.
5. **A short wait shows nothing; a long one shows honest progress.** A spinner or skeleton waits `delay-spinner` (300 ms) and then stays at least `hold-spinner` (500 ms) (**DelayedProgress**). A bar moves to each value over `motion-progress` (250 ms, linear) whenever the size is known.
6. **Nothing moves on its own.** No pulse, breathing, glow or shimmer. The one loop is the spinner, and only while work really runs. The skeleton is a still `subtle` shape.
7. **Something that arrives moves `motion-shift` (8) as it fades in**: a notice from above, a card from below. A card that arrives on its own, such as the approval card, ignores clicks and taps for `guard-click` (300 ms). The keyboard is never blocked.
8. **Reduce Motion means fades.** Nothing travels, slides or scales. Every move becomes a `motion-fast` fade, a bar jumps to its value, and the spinner still turns. `G.Motion` does this by itself (`gAnimation`, `gTransition`), so a view never reads the setting.
9. **The system's motion stays the system's.** Sheets, alerts, popovers, menus, split dividers, pull to refresh, Face ID and Liquid Glass toolbars keep their own motion. We never re-animate them.
10. **Haptics on iPhone only, for outcomes.** Success, warning or error when a run the person started ends while its screen is open, and warning when a safety question or approval card appears. Never for scrolling, hover, taps through a list or a background refresh. Always with something visual too. The Mac plays no success or error haptics, so its feedback is visual.

**Copy.** Copying never happens silently: the copy icon becomes `checkmark` in `ok` for `hold-confirm` (1.5 s) with a `motion-fast` replace (**CopyButton**), and VoiceOver says "Copied". Where there is no icon (⌘C in a table, a menu item), the status bar says what was copied for the same time.

**Kept still on purpose:** the ⌘K palette, tab and place switches, keyboard moves and scroll-to-selection, terminal and log text, query results and command output, selection fills and markers, status dots and pills, rows inside long lists (no animated inserts or removals), hover coming in (instant), and the system's own sheets and menus. A card README says "Motion: none" when its stillness is on purpose.

**In each card's README**, a line in one shape: `Motion: <moment> → <token> (<what moves>). Reduce Motion: <fallback>. iPhone: <haptic or none>.`

**In Swift**, use only `G.Motion` (`gAnimation(.base, value:)`, `gTransition(.appear)`, `withGAnimation(.base) { }`). On the phone the same tokens are `G.Motion` (`gAnimation(.fast, value:)`, `withGAnimation(.base, reduceMotion:) { }`). `scripts/check-motion.sh` (`make lint`, both apps) fails on a literal curve, `withAnimation` or `.repeatForever` outside `Motion.swift`. Debug snapshots turn every G.Motion animation off, so renders are the same every time.

## Iconography

- Use **SF Symbols** by name, at the weight of the text beside them, and never make a custom icon set. These are the symbols in use:

| Meaning | Symbol |
| --- | --- |
| Home · Hosts · Connections | `house` · `server.rack` · `cylinder.split.1x2` |
| VPN (in Connections) · Port Forwarding · Jobs | `network.badge.shield.half.filled` · `arrow.left.arrow.right` · `gearshape.2` |
| Recipes · Keychain · Audit Log | `curlybraces` · `key` · `clock.arrow.circlepath` |
| Terminal · findings | `terminal` · `stethoscope` |
| Menu bar, idle · running · Import | `terminal` · `terminal.fill` · `square.and.arrow.down` |
| Agent · Files · Split Right · Split Down · Broadcast Input | `text.bubble` · `folder` · `rectangle.split.2x1` · `rectangle.split.1x2` · `antenna.radiowaves.left.and.right` |
| Caches · Storage · Clusters · Registries · Queues · Other | `memorychip` · `archivebox` · `circle.hexagongrid` · `shippingbox` · `tray.full` · `questionmark.circle` |
| Search · New · Close · Refresh · More | `magnifyingglass` · `plus` · `xmark` · `arrow.clockwise` · `ellipsis` |
| Run or send · Prompt · Link | `arrow.up` on a 28 rounded square · `chevron.right` · `link` |
| Error · Warning · Success · Protected | `exclamationmark.circle.fill` · `exclamationmark.triangle.fill` · `checkmark.circle.fill` · `lock.fill` |

- Put a target's symbol in an **IconTile**: its family tint at 12% behind the glyph, `.medium`, corner `radius-tile`. Tiles come in five sizes with fixed glyphs: 20 (glyph 12), 28 (16), 32 (16), 40 (20), 48 (24).
- Icons come in `icon-xs`, `icon-sm`, `icon-md`, `icon-lg` and `icon-2xl`. Inline icons in rows are `icon-md` in `text3`, or `text` when the row is selected.
- **When an icon has color.** Only three things are colored: a **tile for a kind of target** (IconTile in its family tint: servers, databases, caches and so on), the **agent's mark** (`text.bubble`) in `accent`, and **status** (`ok` check, `warn` lock or triangle, `danger` cross). Everything else is a plain glyph in `text3`, `text` when selected: places, actions in ⌘K (Add…, Run a Command…), feature lists in Settings, menu items, tree rows. A chosen item is never marked by turning its icon `accent`; use `text`, weight or a fill.
- **Flag:** SF Symbols cannot be published outside Apple platforms, so the previews draw simple stand-in glyphs, keyed by the same names. Use the real symbol in Swift.

### Owner answers (R-37)

- Gradients. Owner answer 2026-11-09: everything is one solid fill, the avatar included; only the logo ground and the skeleton shimmer keep a gradient, each for the reason given under Layout rules.
- Composer shadow. Owner answer 2026-11-09: fix everything, so the agent's composer has no shadow and keeps its border.
- Pill tint. Owner answer 2026-11-09: fix everything, so pills drop from 12% to 10% (`opacity-pill`), the value that gives every status color 4.6:1 or more in both themes.

## In Swift

`G` is Glamor's namespace: `Sources/Glamor/macOS/Tokens.swift` on the Mac and `Sources/Glamor/iOS/Tokens+iOS.swift` on iPhone and iPad. It wraps the vendored `GlamorTokens` (`Sources/Glamor/Generated/GlamorTokens.swift`, copied from efolusi/design-tokens by `scripts/vendor-tokens.sh`) in SwiftUI colours, fonts and lengths, so a view never writes a colour or a number. `scripts/check-colors.sh` and `scripts/check-sizes.sh` enforce it.

The building blocks sit beside the tokens, one file per kind: `Typography.swift`, `Buttons.swift`, `Controls.swift`, `Lists.swift`, `Surfaces.swift`, `Feedback.swift`, `Layout.swift`, `Focus.swift`, `Hover.swift`, `Motion.swift`, `SplitDivider.swift` and `SpinnerGate.swift` on the Mac; `Surfaces+iOS.swift`, `Feedback+iOS.swift`, `Motion+iOS.swift` and `PhoneMotion+iOS.swift` on iOS.

```swift
enum G {
    // Colours: window, panel, card, text, text2, text3, accent, focus, ok, warn, danger, …
    enum Font    { titleL, titleM, titleS, bodyStrong, bodyMedium, body, caption, small, sectionLabel, inputL, monoL, mono, monoS }
    enum Space   { s2, s4, s8, s12, s16, s20, s24, s32, s40, s48 }
    enum Radius  { r4, r6, r8, r12, r16, tile }
    enum Height  { control16 … control40, pill, row32 … row64, tab, toolbar, header, … }
    enum Tile    { t20, t28, t32, t40, t48 }        // glyph(_:): 12, 16, 16, 20, 24
    enum Icon    { xs, sm, md, lg, xl, xxl }        // 8 to 32, from design-tokens icon.*
    enum Dot     { d6, d8 }
    enum Line    { hair, strong, focusOffset, bar }
    enum Width   { sidebar, inspector, sidePanel, chat, palette, menu, sheet, … }
    enum Hover   { onCard, onPanel, onTab, onWindow, pressed }
    enum Shadow  { control, hover, panel, palette }  // drawn with .shadow(G.Shadow.panel)
    enum Opacity { tint, pill, increased, banner, bannerEdge, attention, attentionEdge, ring, kbd, softHairline, chip, disabled }
    enum Motion  { fast, base, slow, progress, shift, … }   // MotionSpec
}
```

```swift
// A section of a page
VStack(alignment: .leading, spacing: G.Space.s16) {
    HStack(alignment: .top) {
        SectionTitle("Needs attention", subtitle: "2 findings from the last check")
        Spacer()
        LinkButton(title: "View all 4") { model.go(.findings) }
    }
    LazyVGrid(columns: [GridItem(.flexible(), spacing: G.Space.s16), GridItem(.flexible(), spacing: G.Space.s16)], spacing: G.Space.s16) {
        ForEach(items) { AttentionCard(item: $0, confirm: $confirm) }
    }
}
DashedDivider()
```

- Use only `K.*`, never a literal color or size in a view. The one exception is a family tint, which belongs on `Family.tint`.
- Set text with `.textStyle(.caption)` and the other styles: each carries its 16, 20 or 24 line and centres the text in it.
- Use the button styles `.primary`, `.secondary` and `.ghost` (32), with `compact: true` or `.controlSize(.small)` for 28. The sidebar has no create button; **Add** (⌘N) sits in the panel header.
- Use `.card()`, `.card(padding: G.Space.s16)` and `.surface()` instead of repeating backgrounds and overlays.
- `scripts/check-sizes.sh` fails the build check when a view uses a number that is not on the scale. Run it before every change to a view.
- Keep SwiftUI's own controls where the system draws them: `Toggle(.switch)`, segmented `Picker`, `Menu`, `.alert`, `.popover` and `.sheet`. They take the system accent color, not `G.accent`.
