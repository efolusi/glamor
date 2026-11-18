# Card

The basic container: `card` with a 1pt `border` hairline drawn inside and `radius-12`, with no shadow at rest. In Swift, use `.card()`, `.card(padding: 16)`, `HoverCard(action:) { … }` for a clickable card, and `.surface(padding:)` for a quiet `subtle` well around code.

**Provide:** the content and the padding: 16 for every card, HoverCard included.

- A clickable card is always a `HoverCard`: `cardHover` and `shadow-hover` under the pointer, with a context menu for secondary actions (Open, Copy Name, Copy Address).
- Use `.surface` for output and commands, never for content cards.
- Don't nest cards, colour a card's border by category, or add a shadow at rest.
