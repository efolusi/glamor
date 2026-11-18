# EmptyState

A centred, quiet state for when there is nothing to show: a 32 light symbol in `text3`, a title, a line or two, and optional actions. In Swift: `EmptyState(symbol: "arrow.left.arrow.right", title: "No forwards open", message: "…") { Button("New Forward") {…}.buttonStyle(.primary) }`.

**Provide:** the symbol of what is missing, a short title ("No forwards open", "No jobs recorded", "Nothing matches"), one or two sentences that say how to get some, and at most one primary action.

- The message is at most 440 wide and points at the next step ("Add one in the console: vpn add NAME KIND.").

- Motion: none. It replaces the list at once.
- **VoiceOver** reads the title as a heading; the symbol above it is decoration and is skipped.
