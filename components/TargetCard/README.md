# TargetCard

A target in the inventory: its family tile, its name and where it is, and a lock when it is protected. In Swift: `TargetCard(target: t)`, built on `HoverCard`, with a context menu (Open, Open Terminal, Copy Name, Copy Address).

**Provide:** the target's family symbol and tint, its name, and a subtitle joined with " · " (kind, address, "via bastion").

- The lock is `lock.fill` at 12 in `warn`, with the help text "Protected: changes need your confirmation".
- A server's subtitle omits the kind, because the tile already says it.
