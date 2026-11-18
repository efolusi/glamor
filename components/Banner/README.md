# Banner

An inline message after an action: **ErrorBanner** (a `danger` icon on a 10% tint with a 25% stroke) or **SuccessBanner** (an `ok` icon on a 10% tint). In Swift: `ErrorBanner(title: e.message, hint: e.hint)` and `SuccessBanner(title: "Forward started", detail: output)`.

**Provide:** the title, which is what happened in komando's words, and optionally a hint or detail, which is what to do or what komando printed.

- Place a banner where the action happened, above the buttons of the form or section. It is never a toast.
- The title is `text` medium and the hint is `text2`, both selectable so they can be copied.

- Motion: arrives → motion-base (fades in, motion-shift 8 from above; what sits below moves with the same spring) and leaves with a motion-base fade. Reduce Motion: a motion-fast fade, nothing travels. iPhone: success or error haptic when it reports the person's own action.
- **VoiceOver** reads the kind before the title, so it is not told by color and shape alone: "Done" (`success`), "Warning", "Error" (`danger`) or "Note" (`info`). In Swift: `Banner.spokenKind`.
