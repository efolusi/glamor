# Beginner UX review

Komando's goal is to be easy for a beginner. A review of 18 screens of the Mac app against a real inventory (50 targets, 71 jobs) found the visual style calm and right, and the structure too heavy: too many ways in, and the same facts shown two or three times. The proposed screens add surface without taking any away. The user adopted all of it on 2026-11-08: the rules are now the brand book's **Layout rules**, and the screens and journeys follow them. This section keeps the findings and the reasons.

## Rules

- **One primary button per screen.** The create button sits only at the right of the panel header, named for what it makes (Add on Hosts and Connections, New Forward, New Recipe, New Secret).
- **Advanced features hide until asked.** Split Right, Split Down, Broadcast Input, Dry Run and view switches go in ⋯ menus or shortcuts, not toolbars.
- **One object opens one way.** A host or connection opens as a tab, not a tab and an inspector.
- **A fact appears once per screen.** No address in both the subtitle and a card, no groups as both pills and a row, no Shell button twice.
- **One search.** ⌘K in the sidebar; pages don't repeat it with their own search bar, except to filter a long list.

## 1. Sidebar: 5 places instead of 12

- Keep **Home, Hosts, Connections, Port Forwarding, Recipes**.
- **Doctor** becomes part of Home: Needs attention already shows its findings, and the full list is its "View all".
- **Console** becomes "Run a Command…" in ⌘K.
- **VPNs** become a section of Connections; komando brings them up by itself.
- **Jobs, Keychain, Audit Log** go under a collapsed **More**.
- **Agent** opens as the ⌘J drawer from anywhere, not as a twelfth place.

## 2. A lighter sidebar footer

The status line, the license card and the profile card take about 210 of an 840 window, and squeeze GROUPS to one clipped row.
- The license card goes. The profile row keeps the name and "Local · on this Mac", with no plan pill: since 2026-11-12 the apps are free with no trial.
- The komando version moves into the profile menu, under "Free · everything on this Mac" ("komando 1.4.0 · 21 targets"); the sidebar has no status dot (2026-11-09; this first said the status dot's tooltip).
- GROUPS leaves the sidebar (see 4).

## 3. One create button, one search

- The sidebar's black "New Host ⌘N" opens a choice of Host or Connection, so its label is wrong; the sidebar keeps Search only. Since 2026-11-09 one **Add** (⌘N) opens a chooser of every kind, with the importers on it (**PageAdd**); on Hosts it opens the Server form straight away.
- Hosts repeats New Host, Connections has New Connection, and an empty Port Forwarding shows New Forward twice: one each, in the header (now **Add** on Hosts and Connections).

## 4. Inventory as a list, not cards

- 22 PostgreSQL cards in three columns truncate their names until cards look identical. A one-line list (full name · kind · address · lock) keeps names whole and scans down one column.
- The Hosts group cards repeat the sidebar's GROUPS, and a group that holds every host helps no one choose. Both become one chip row: All · dev · stg · prd · prdnew.
- PageHosts' Grid/List switch and inspector go; the list and the chips stay.

## 5. Host detail: one main action

- Five ways to run something (Shell in the header, the Run, Recipes and Inspect tabs, Console) become one primary **Open Terminal**.
- Server tabs become **Overview · Terminal**; Inspect's Facts, Services and Certificates and the top recipes become "Quick checks" on Overview.
- A database gets **Overview · Query**, with the schema at the side as PageDatabase shows.
- Overview's content lines up with the header's left edge.

## Smaller findings

- **Running now** shows VPNs and forwards only; jobs become one line ("71 background jobs · View"). A running thing is never `warn`.
- **Needs attention** speaks plainly: "duwit-stg-redis runs on a protected server but isn't protected." with **Protect**; "Copy Fix" becomes **How to Fix**, a sheet that explains a change komando can't make for you (**PageHowToFix**).
- **One safety control everywhere:** ☐ Allow changes, off by default. Today a server shows ☑ Read-only and a database ☐ Allow writes, and the agent has Ask and Act; all become the same box. Dry Run moves into the ⋯ menu.
- **Doctor and Jobs** stop showing raw CLI text (`!` marks, backticks, job ids); "Ask the Servers" says what it does.
- **Less decoration:** the date in the Home header, the inventory card (it repeats the sidebar counts), shortcut badges everywhere, the license card's gradient (gone with the card) and the group bars. Shortcuts move to tooltips and menus.

## Keep

The Server form (New Host, the most beginner-friendly screen), the kind chooser (now **PageAdd**, one Add for every kind; the Kind menu in New Connection no longer holds VPNs or the importers), empty states with example buttons, the safety confirmations and the ⌘K palette.

## Screens that changed

AppShell, PageDashboard, PageHosts, PageHostDetail, PageConnections (VPNs are a section of it now), PageDoctor, PageTerminal, PageAgentStart and PageAgentDrawer, and journeys 2, 3 and 8.
