# Button

Three button styles: **primary** is black (white in dark), **secondary** is a raised card with a hairline, and **ghost** is text that gains a fill under the pointer. In Swift: `.buttonStyle(.primary)`, `.secondary` or `.ghost`, and `PrimaryButtonStyle(shortcut: "⌘N", wide: true)` for the sidebar's main action.

**Provide:** a Title Case verb label, and optionally an SF Symbol through `Label("New Host", systemImage: "plus")`.

- Each view gets **one primary**, for the action the view exists for: New Host, Save, Check Again, Open Terminal. A sheet that only informs, like Upgrade, has none: its Close is secondary.
- Use **secondary** for every other real action: Run Doctor, Fix, Copy Command, View, Cancel.
- Use **ghost** for small in-place actions: Stop, the refresh arrow, items in a popover.
- Show the shortcut badge only on a primary button. Elsewhere, put the shortcut in `.help("Run (⌘↩)")`.
- A destructive confirmation says what happens (Run Anyway, Allow Once). Use the system `.alert` with `role: .destructive` for it, not a red custom button.
- Focused (keyboard): a 2pt `focus` line with a 2pt gap, the same for every style (Save in the preview: the gap keeps the line off the black fill): `RoundedRectangle(cornerRadius: r + 4).strokeBorder(K.focus, lineWidth: 2).padding(-4)` over the button, drawn when `@Environment(\.isFocused)` is true; the system's square focus rectangle is turned off with `.focusEffectDisabled()` only where this ring is drawn.
- Hover and pressed: primary `accentHover` then `accentPressed` (opaque); secondary `cardHover` then `pressed`; ghost `hover-panel` (or `hover-card` inside a card) then `pressed`, with `text`. A destructive secondary (Remove…) hovers the same; only its word is `danger`. Disabled is `opacity-disabled` with no shadow, or `text3` on a secondary button.
- Shadow: `shadow-control` on primary and secondary (K.Shadow.control), none on ghost.

- Motion: hover and press change at once. A copy button is a **CopyButton**: its `square.on.square` is replaced by `checkmark` in `ok` over motion-fast for hold-confirm (1.5 s), then comes back, and VoiceOver says "Copied". Reduce Motion: the same. iPhone: success haptic on copy.
