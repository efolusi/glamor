# Button

Three button styles, all drawn as capsules (a ghost menu row, `wide`, keeps the row's `radius-8`; an icon-only button is a circle): **primary** is the owl's copper with an ink label and a 1px `accentEdge` rim (the fill alone is 2.7:1 on a card in light; the rim is 4.6:1; on the solid button it is the fill's own colour in dark, on glass it is a 1px line over a translucent tint), **secondary** is a raised card with a hairline, and **ghost** is text that gains a fill under the pointer. In Swift: `.buttonStyle(.primary)`, `.secondary` or `.ghost`, and `PrimaryButtonStyle(shortcut: "⌘N", wide: true)` for the sidebar's main action.

**Provide:** a Title Case verb label, and optionally an SF Symbol through `Label("New Host", systemImage: "plus")`.

- Each view gets **one primary**, for the action the view exists for: New Host, Save, Check Again, Open Terminal. A sheet that only informs, like Upgrade, has none: its Close is secondary.
- Use **secondary** for every other real action: Run Doctor, Fix, Copy Command, View, Cancel.
- Use **ghost** for small in-place actions: Stop, the refresh arrow, items in a popover.
- Show the shortcut badge only on a primary button. Elsewhere, put the shortcut in `.help("Run (⌘↩)")`.
- A destructive confirmation says what happens (Run Anyway, Allow Once). Use the system `.alert` with `role: .destructive` for it, not a red custom button.
- Focused (keyboard): a 2pt `focus` line with a 2pt gap, the same for every style (Save in the preview: the gap keeps the line off the copper fill): `Capsule().strokeBorder(K.focus, lineWidth: 2).padding(-4)` over the button (`focusRingCapsule()`; a rounded row uses `RoundedRectangle(cornerRadius: r + 4)`), drawn when `@Environment(\.isFocused)` is true; the system's square focus rectangle is turned off with `.focusEffectDisabled()` only where this ring is drawn.
- Hover and pressed: primary `accentHover` then `accentPressed` (opaque); secondary `cardHover` then `pressed`; ghost `hover-panel` (or `hover-card` inside a card) then `pressed`, with `text`. A destructive secondary (Remove…) hovers the same; only its word is `danger`. Disabled is `opacity-disabled` on the primary's fill and rim, with no shadow (the label stays ink), or `text3` on a secondary button.
- Shadow: `shadow-control` on primary and secondary (K.Shadow.control), none on ghost.

- Motion: hover and press change at once. A copy button is a **CopyButton**: its `square.on.square` is replaced by `checkmark` in `ok` over motion-fast for hold-confirm (1.5 s), then comes back, and it posts the accessibility announcement "Copied" (VoiceOver speech is not machine-proven). Reduce Motion: the same. iPhone: success haptic on copy.
