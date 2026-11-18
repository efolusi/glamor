# Iconography audit

Proposed, not adopted. The README's Iconography section still lists the symbols in use, and the Swift views still draw them. This audit lists the places where one meaning has several symbols, or one symbol several meanings, and the set and rules that would fix them. The **IconAudit** card draws each finding, today next to proposed.

Symbols are named, not cited by line, because the Swift views are being moved to the 4-point scale and their line numbers will change.

## Findings

1. **Failure has two symbols.** A failed connection test shows `xmark.octagon.fill` and a failed command `xmark.circle.fill`. Use `xmark.circle.fill`, the pair of `checkmark.circle.fill`, for every failed result.
2. **An error drawn as a warning.** The "komando did not answer" empty state uses `exclamationmark.triangle`. Use `exclamationmark.circle`; the triangle belongs to `warn`.
3. **A lock means two things.** `lock.fill` marks a protected target and also stands for a secret (New Secret, the secret rows). Keep the lock for protected; a secret takes `key`, as the Keychain does. Nothing is locked for money: the apps are free.
4. **Feature lists invent symbols.** The old license window drew `list.bullet.clipboard` and `lock.shield`. A feature list (now only the Upgrade sheet) reuses the symbols of the places it names: `clock.arrow.circlepath` for the audit log, `lock.fill` for protected changes, `text.bubble` for anything the agent does.
5. **Groups look like the Dashboard.** Group cards show `square.grid.2x2.fill` and the group activity `square.grid.2x2`, the Dashboard's symbol. Use `square.stack.3d.up` for a group.
6. **Jobs look like Settings.** `gearshape.2` for Jobs sits next to `gearshape` for Settings… A job is a long command that keeps running on its server: use `play.square.stack`.
7. **Family tints outside their family.** Keychain keys sit on a `tint-registries` tile and jobs on a `tint-clusters` tile. A family tint goes on that family's tile only; use `text2` for these.
8. **Filled glyphs in tiles.** `square.grid.2x2.fill`, `key.fill` and `lock.fill` appear in tiles, while every family tile is outline. Use outline glyphs in every tile.
9. **New tabs use two plus shapes.** The New Host tab shows `plus.rectangle.on.rectangle` and the New Connection tab `plus.circle`, while the New menu shows `server.rack` and `cylinder.split.1x2`. A tab shows what it holds; `plus` stays on buttons.
10. **A bolt means two things.** The connection test is `bolt.heart`. Use `waveform.path.ecg` for the test. (Caches were a bolt too; they are `memorychip` now.)
11. **The install screen borrows a family symbol.** "Install the komando command line" uses `shippingbox`, the Registries symbol. Use `terminal`.
12. **Unknown has three symbols.** A missing target shows `questionmark.circle`, an unknown tab `questionmark`, an unknown activity `circle.dashed`. Use `questionmark.circle` for all three.
13. **Small glyphs change weight and color.** `chevron.right` is `.semibold` in links and `.bold` in the prompt, `xmark` is `.bold`, and the table list in the database client uses the system's secondary grey. Small glyphs are `icon-xs` or `icon-sm` at `.semibold`, and every glyph takes its color from the tokens.

## One meaning, one symbol

Symbols marked *new* are new to the app. Their stand-ins are in the bundle's map, so **SFSymbol** draws them. Check every new name in Apple's SF Symbols app before it goes into Swift.

| Meaning | Today | Proposed |
| --- | --- | --- |
| Dashboard | `square.grid.2x2` | `square.grid.2x2` |
| Hosts · Connections · VPNs | `server.rack` · `cylinder.split.1x2` · `network.badge.shield.half.filled` | unchanged |
| Port Forwarding · Recipes · Keychain | `arrow.left.arrow.right` · `curlybraces` · `key` | unchanged |
| Audit Log · Console · Doctor | `clock.arrow.circlepath` · `terminal` · `stethoscope` | unchanged |
| Jobs | `gearshape.2` | `play.square.stack` *new* |
| Settings | `gearshape` | `gearshape` |
| A group | `square.grid.2x2`, `square.grid.2x2.fill` | `square.stack.3d.up` *new* |
| A secret | `key`, `key.fill`, `lock.fill` | `key` |
| Connection test | `bolt.heart` | `waveform.path.ecg` *new* |
| Upgrade | `checkmark.seal` (License…) | `arrow.up.circle` (Upgrade…) |
| Protected | `lock.fill`, `lock.shield` | `lock.fill` |
| Unknown | `questionmark.circle`, `questionmark`, `circle.dashed` | `questionmark.circle` |
| Success | `checkmark.circle.fill` | `checkmark.circle.fill` |
| Failed | `xmark.circle.fill`, `xmark.octagon.fill`, `exclamationmark.triangle.fill` | `xmark.circle.fill` |
| Error | `exclamationmark.circle.fill`, `exclamationmark.triangle` | `exclamationmark.circle.fill`, `exclamationmark.circle` in empty states |
| Warning | `exclamationmark.triangle.fill` | `exclamationmark.triangle.fill`, in `warn` only |
| A New Host or New Connection tab | `plus.rectangle.on.rectangle`, `plus.circle` | `server.rack`, `cylinder.split.1x2` |
| Installing komando | `shippingbox` | `terminal` |
| Caches · Storage · Clusters · Registries · Other | `memorychip` · `archivebox` · `circle.hexagongrid` · `shippingbox` · `questionmark.circle` | unchanged |
| Queues (Kafka, RabbitMQ, NATS JetStream, SQS, Pub/Sub) | `questionmark.circle` (fell into Other) | `tray.full` on `tint-queues` *new* |
| New · Close · Search · Refresh · More | `plus` · `xmark` · `magnifyingglass` · `arrow.clockwise` · `ellipsis` | unchanged |
| Prompt · Edit · Start · Run | `chevron.right` · `pencil` · `play.fill` · `arrow.up.circle.fill` | unchanged |

## Rules

1. **One meaning, one symbol.** A symbol names a place or a thing. Lists, tabs, tiles and buttons about that thing reuse it, and no symbol stands for two things.
2. **Outline by default.** `.fill` is only for status glyphs, in their status color and next to a word, and for Run.
3. **Sizes from the scale.** Glyphs in rows are `icon-md` with no frame. Chevrons, close marks and the lock in a pill are `icon-xs` or `icon-sm` at `.semibold`. Tiles are 20, 28, 32, 40 and 48 with glyphs of 12, 16, 16, 20 and 24 at `.medium`. Empty states are `icon-2xl` at `.light`.
4. **Color from the tokens.** Glyphs in rows are `text3`, or `text` when the row is selected. A family tint goes only on that family's tile; places and other things use `text2`, new items `accent`. Status colors appear only on status glyphs.
