# Notifications

The notices Komando posts through macOS (`Notifier`) when something stops while the window is closed or behind other windows: a forward or a VPN. An app-only feature, free like the rest of the app.

- **The system draws them.** A macOS banner with the app icon from Logos (not **AppLogo**), the title in bold and one sentence under it; the preview redraws it with `panel`, a `border` hairline, `shadow-palette`, `radius-16` and `space-12` inside. No status color: the words say what happened.
- **Title says what stopped, the sentence says which and what next.** "Forward stopped" · "localhost:15432 → prod-db is no longer open." · "VPN disconnected" · "office is down. komando brings it up again when a target needs it." Use the forward's own title (local address → target) and the VPN's name, as on Home and in the menu bar.
- **When.** Komando reads `komando status` every 5 seconds; a forward that was open and is now stopped or gone, or a VPN that is no longer listed, posts once. Those two are the only notices: Komando never posts about a plan or a price.
- **Asked once, turned off in one place.** The first notice asks macOS for permission. **Notify me when a forward or VPN stops** in Settings (**PageSettings**) turns every notice off.
- **Locked, a notice names nothing.** A notice can show on the lock screen. While the Mac's screen is locked, or Komando is locked with Touch ID (**PageAppLock**), the sentence leaves out the address, the target and the VPN's name: "Forward stopped" · "A forward is no longer open." · "VPN disconnected" · "A VPN is down. komando brings it up again when a target needs it." The names are in the app once it is unlocked.
- **Inside the app, nothing new.** A stopped forward also shows Stopped in `danger` on its row (**PagePortForwarding**); the notification is for when the window is not in front.

- Motion: a notice above the page arrives as a **Banner** (motion-base, 8 from above) and a success leaves after hold-notice (8 s) with a fade. A failure stays until Dismiss. Running counts change at once. Reduce Motion: a motion-fast fade. iPhone: success or error haptic for the person's own action. A system notification keeps the system's motion.
