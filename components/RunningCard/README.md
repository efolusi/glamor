# RunningCard

Something komando keeps going, such as a VPN, a forward or a job: what it is, where it goes, its state and for how long. In Swift: `RunningCard(symbol:tint:title:line:chip:chipColor:meta:action:)`, built on `HoverCard`.

**Provide:** a symbol and tint (the family's), a title, one line in mono (kind, `→ target` or the command), a chip word with its tone, and relative-time meta.

- Use the chips Up or Open (`ok`), Stopped (`danger`) and Job (`text2`). The chip alone says the state: no status dot beside the title, so the same fact is not shown twice.
- Lay the cards out in adaptive columns of at least 248, and show "All n jobs" past six.
