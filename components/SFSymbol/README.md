# SFSymbol

Stand-in glyphs for the SF Symbols the app uses, keyed by the same names. In Swift, write `Image(systemName: "server.rack")` and let the surrounding font set its size and weight. Never ship these SVGs in the app; they exist only so the previews can be drawn outside Apple platforms.

**Provide:** `name` (the SF Symbol name), `size` in points, `weight` (`light`, `regular`, `medium`, `semibold`, `bold`) and `color` (a token name). A name without a stand-in draws `circle.dashed`.

- Sizes: `icon-xs`, `icon-sm`, `icon-md`, `icon-lg`, `icon-2xl`. Row icons are `icon-md` in `text3`, or `text` when the row is selected.
- Give it the weight of the text beside it: `.medium` in tiles, `.semibold` or `.bold` on chevrons and the prompt.
- Don't draw a custom icon where an SF Symbol exists, or mix icon sets.
- **VoiceOver.** A symbol is decoration unless it says something the words beside it do not: `Image.icon(_:)` hides it, so its symbol name is never read out. A symbol that carries meaning ("Problem", "Warning", "Primary key") takes `icon(_:label:)`, and a symbol inside a button is named by the button. The ⋯ button says what it is for: "More for web-1" (`MoreMenu(label:)`).
