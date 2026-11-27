# ProfileCard

The person at the very bottom of the sidebar: an initial in a circle, their name and where the data lives, with a `chevron.up.chevron.down` (12, `text3`) at the right. Pressing the row opens the profile menu in a popover. In Swift: `ProfileCard(name:detail:style:menu:)` (`Sources/Glamor/macOS`), drawn in the `profile` scene of the gallery, and as the rail's footer in the `sidebar-b` scene. `style: .row` is the two-line row of the full sidebar; `style: .avatar` is the circle alone, a 44 point button, for the rail (**SidebarRail**).

**Provide:** the name, the detail line and the menu's content: Glamor knows no person. The web kit's card reads the macOS user's name.

- **VoiceOver reads one button, "name, detail"** (the same in both styles); the initial and the chevron are hidden. The tooltip is the same words. With no detail the name is the whole label; with no letter in the name the circle shows a person glyph.
- **The menu** is the caller's view, 260 wide (`G.Width.profileMenu`) in a popover that opens above the row (beside the avatar in the rail). Escape closes it and the system returns focus to the card; the window check proves both in the `profile` scene.

- It is the whole sidebar footer. It shows no plan pill: the apps are free, with no trial, so there is nothing to count down or unlock. With no pill, the name has the row's whole width ("Bartholomew" in the second preview).
- **The profile menu** (a **Popover**, drawn on **PageSettings**): your name, "Free · everything on this Mac" in `caption`, and "komando 1.4.0 · 21 targets" in `meta`, or "komando is not answering" when komando does not answer or is missing. The sidebar has no status dot, so this line and Settings › General are where the komando version shows. Then Appearance (System, Light, Dark), a hairline, **Upgrade…** (**PageUpgrade**) and **Settings…** (**PageSettings**).
- **Proposed (Komando Cloud, the upgrade, nothing built).** Signed in, the menu also holds **Account…** (**PageAccount**) and **Team…** (**PageTeam**); signed out, nothing changes.
- The second line is "Local · on this Mac" in today's app, because nothing leaves the Mac.
- The avatar is one solid `avatar` fill (a soft warm tile: `avatarBg` in design-tokens), with no gradient. Its initial is `onAvatar`, held at 4.5:1 in all four modes (`ProfileCardContrastTests`). The circle itself is a soft tile (1.06:1 off the window in light), so the initial says who it is; it is not gated as a shape.
- Under the pointer the row turns `cardHover`, as a raised control; pressed, `pressed`. It casts no shadow: a HoverCard's `shadow-hover` would lift the sidebar's footer off the window.
