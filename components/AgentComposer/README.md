# AgentComposer

Where the person writes to the agent. It shows the targets in scope as removable chips, a field, @ and attach, the one safety control every page uses, **☐ Allow changes** (off by default; ticked it adds "Each change asks first" in `warn`), and the send button.

**Provide:** the text, the targets in scope and whether Allow changes is ticked (`allowChanges`).

- Everything in it is a rounded square: target chips are 28 with `radius-6` (not capsules), and send is a 28 `radius-6` button with `arrow.up`, `subtle` with a `text3` arrow while the field is empty and `accent` with a white arrow once there is text.
- Return sends, Shift-Return adds a line, @ adds a target or group, ⌘J focuses the composer from anywhere.
- Unticked, the agent runs only commands that look (tooltip "Off: the agent runs only commands that look. On: it may change things, and every change asks you first."). Ticked, it may change things, but every safety stop becomes an **ApprovalCard**. There is no Ask/Act switch and no "Read-only" label: the box reads the same as on a database's Query tab and a cache's Keys tab (beginner review: one safety control everywhere). The preview shows it off (top) and ticked (bottom).
- On iPhone and iPad, the Agent tab has the same safety control as an iOS switch, off by default, and the field has the same `controlEdge` outline. At accessibility text sizes the switch moves into the conversation and only the field and Send stay pinned (**PageiPhoneAgent**).
