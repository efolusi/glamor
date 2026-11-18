# GroupRow

**Retired.** The beginner review removed GROUPS from the sidebar: groups are a chip row on Hosts (All · production · staging · lab), and the ratio bars were decoration. Kept only until the Mac app drops it.

A group of targets in the sidebar: a dot for how much of it is protected, its name, a ratio and a thin bar. In Swift: `GroupRow(row: .init(name: "production", total: 4, protected: 4))`.

**Provide:** the group name, how many targets are in it, and how many are protected.

- The color follows the ratio: `ok` when all are protected, `warn` when some are, and `text3` when none are. The row is 40 high; the bar is `bar` (4) on `border`.
- The section label above is "GROUPS" in `section-label`. Rows are ordered by size and the help reads "3 of 4 protected".
