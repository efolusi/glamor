# ApprovalCard

The agent asks before anything komando would stop for safety, in the same words as the app's safety prompts. The card is `warn` at 5% with a 25% border (`opacity-attention-stroke`, as an AttentionCard).

**Provide:** a title that names the risk ("prod-db is protected", "This command looks destructive", "This changes data"), one line of detail, the exact command with the flag that would be added, and buttons that say what happens.

- **Allow Once** runs it once with the flag; **Don't Run** tells the agent no and it continues without it. Never "OK" or "Cancel".
- On iPhone, **Allow Once** asks for Face ID before the command runs.

- Motion: arrives → motion-base (fades in, motion-shift 8 from below), and the conversation scrolls to it with motion-base unless the person has scrolled up; then a "1 approval waiting ↓" chip shows at the bottom edge (drawn under the card here): a 28 capsule on `card` with a `border` line, the `warn` triangle (12), the words in `caption` medium, and `arrow.down` (12, `text3`). It counts every approval still waiting out of view ("2 approvals waiting"); clicking it, or Return on it, scrolls to the first one, and it goes once every waiting card is in view or answered. VoiceOver: "1 approval waiting, button". For guard-click (300 ms) it ignores clicks and taps, so a click meant for the old layout can't press Allow Once. The keyboard is never blocked, and nothing is dimmed. Reduce Motion: a motion-fast fade, and the scroll jumps. iPhone: warning haptic when it arrives.
