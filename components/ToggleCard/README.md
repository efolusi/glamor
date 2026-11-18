# ToggleCard

A bordered card with a title, a line of help and a small switch. When the switch is on, the card reveals more fields. In Swift: `ToggleCard(title: "Reach through a server or VPN", help: "Connect through a server (bastion) or a VPN. No local port is opened.", isOn: $useVia) { ViaPicker(via: $via) }`.

**Provide:** the title, one help sentence, a binding, and optional extra content.

- Use it for an option that changes how something works and may need its own fields (Reach through a server or VPN, Protected).
- The title names the feature and the help says what turning it on means ("For production: every change needs your confirmation.").
- The switch is the system `Toggle(.switch)` at `.controlSize(.small)`, which takes the system accent color.
