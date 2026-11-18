# MotionSpec

How Komando moves, and when it doesn't. Motion only explains a change: *what changed*, *where it went*, or *that it is still working* (owner decision 2026-11-15; design/README.md › Motion has the ten rules). The cards are still pictures, so this card shows each token live, with **Replay**, and draws the start and end frames the app's gallery draws.

**Tokens** (tokens.json › motion, `K.Motion` in `DesignSystem/Motion.swift`):

| Token | Value | Swift | Use |
|---|---|---|---|
| `motion-fast` | 120 ms, ease-out | `K.Motion.fast` | Symbol replace, the copied check, the drop ring, the lock cover; also the Reduce Motion fade |
| `motion-base` | 200 ms, spring, bounce 0 | `K.Motion.base` | A notice, banner or approval card arriving or leaving |
| `motion-slow` | 250 ms, spring, bounce 0 | `K.Motion.slow` | A panel: the agent drawer, the transfer queue folding. Nothing is longer |
| `motion-progress` | 250 ms, linear | `K.Motion.progress` | A progress bar moving to its value |
| `motion-shift` | 8 | `K.Motion.shift` | How far an arriving thing travels |
| `delay-spinner` | 300 ms | `K.Motion.spinnerDelay` | A spinner or skeleton waits this long |
| `hold-spinner` | 500 ms | `K.Motion.spinnerHold` | Once shown, the shortest time it stays |
| `hold-confirm` | 1.5 s | `K.Motion.confirmHold` | The copied check |
| `hold-notice` | 8 s | `K.Motion.noticeHold` | A success notice |
| `guard-click` | 300 ms | `K.Motion.clickGuard` | A card that arrives on its own ignores clicks this long |

`ease-out` and `ease-spring` are the CSS curves the cards use for the Swift ones.

**The demos:** Copy, Notice arrives, Approval card arrives, Progress, Spinner (try Fast and Slow), Run ends, and Agent drawer. The **Reduce Motion** switch (on by itself when the Mac's Reduce Motion is on) shows the fallback: nothing travels or scales, moves become a 120 ms fade, a bar jumps, and the spinner still turns.

**Start and end frames.** The app draws the same rows with its own views (`KOMANDO_APP_PAGE=motion`, `MotionGallery`), with animations off, so the two can be compared side by side as stills. The durations are in the notes under each frame.

**Building blocks in Swift:**
- `gAnimation(.base, value:)`, `gTransition(.appear(from: .top))` and `withGAnimation(.base) { }`. Each one follows Reduce Motion by itself.
- `DelayedProgress(isBusy:)`: the spinner that waits 300 ms and stays 500 ms.
- `CopyButton`: the copy icon with its check.
- `ProgressBar`: it eases by itself.
- `Skeleton`: still.
- `.clickGuard()`: for a card that arrives on its own.

`scripts/check-motion.sh` (part of `make lint`) fails on a literal curve, `withAnimation` or `.repeatForever` outside `Motion.swift`.

**Still on purpose:** the ⌘K palette, switching places and tabs, keyboard moves in lists, terminal and log text, command output, selection, status dots and pills, rows in long lists, hover coming in, and the system's sheets, alerts and menus.

**iPhone and iPad:** the same tokens, as `MK.Motion` (`gAnimation`, `withGAnimation`; the times are `PhoneMotion`), checked by the same lint. A spinner in a button's row (Refresh, Verify the Record) and the agent's "Working…" wait delay-spinner; "Copied" stays hold-confirm (1.5 s). The cover the app switcher shows is there at once and fades away over motion-fast when the app comes back. Haptics are for outcomes only:
- success or error when a run, copy or transfer the person started ends while its screen is open;
- warning when a safety question or an approval card appears.

There are no haptics for scrolling, taps through lists or background refreshes. The Mac plays none of these, so its feedback is visual.

**For beginners:** nothing makes you wait, nothing moves unless something changed, and the change is always readable in the first frame.

- Motion: this card is the spec. Reduce Motion: its switch.
