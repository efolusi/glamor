# HopList

The steps komando goes through to reach a target, in order: `--via office,jump1,jump2`. It sits inside the "Reach through a server or VPN" **ToggleCard** on New Host, Edit Host, New Connection and Edit Connection.

**Provide:** the steps (each a name and whether it is a VPN or a host) and the target's name.

- **Rows.** A `surface` list, one 32 row per step, `border` lines between them: the step's number in `caption` `text3`, the family glyph (16, `tint-vpns` or `tint-servers`), the name in mono, "VPN" in `meta` for a VPN, then three ghost `xs` buttons: Move Up (`chevron.up`), Move Down (`chevron.down`) and Remove (`xmark`, tooltip "Remove NAME").
- **A VPN can only be first.** komando brings up one VPN, before the first hop. So Add a Step… offers VPNs only while the list is empty, a VPN never moves down, and a host never moves above it (those buttons are disabled, not hidden). The line under the list says so.
- **Add a Step….** A 32 **PopupButton** with `plus` under the list (an empty list says "Choose a server or VPN…"). Its menu has two sections, VPNs and Hosts, without the target itself and without the steps already there.
- **The last line** says where it ends: "komando goes through these in order, then reaches web-2. A VPN can only be the first step." (one step: "goes through it").
- **What it sends.** The names joined with commas, in order: `--via office,jump1,jump2`. Removing the last step and saving with the switch on sends nothing new; turning the switch off sends `--unset via` (and asks first when there were two or more steps, **PageEditTargetStates**).
- **A route the list cannot draw** (a name that is not in the inventory) still shows as its own row, with `exclamationmark.triangle.fill` in `warn` before the name and the tooltip "komando has no host or VPN by this name". Saving keeps it as it is; komando says why it cannot use it.
- **Access.** The list is a list ("Steps, in order"); each row reads "Step 2 of 3, jump1, host", and the buttons name their step ("Move jump1 up"). Tab reaches each button in order.
- **iPhone and iPad.** No forms there on purpose; the phone shows the route as text.
- Motion: a moved step changes place at once (lists never move, **MotionSpec**).
