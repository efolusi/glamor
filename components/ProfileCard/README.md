# ProfileCard

The person at the very bottom of the sidebar: an initial in a green circle, their first name and where the data lives, with a `chevron.up.chevron.down` (12, `text3`) at the right. Clicking the row opens the profile menu. In Swift, it is `ProfileRow` in the sidebar, with `ProfileMenu`.

**Provide:** nothing. It reads the macOS user's name.

- It is the whole sidebar footer. It shows no plan pill: the apps are free, with no trial, so there is nothing to count down or unlock. With no pill, the name has the row's whole width ("Bartholomew" in the second preview).
- **The profile menu** (a **Popover**, drawn on **PageSettings**): your name, "Free · everything on this Mac" in `caption`, and "komando 1.4.0 · 21 targets" in `meta`, or "komando is not answering" when komando does not answer or is missing. The sidebar has no status dot, so this line and Settings › General are where the komando version shows. Then Appearance (System, Light, Dark), a hairline, **Upgrade…** (**PageUpgrade**) and **Settings…** (**PageSettings**).
- **Proposed (Komando Cloud, the upgrade, nothing built).** Signed in, the menu also holds **Account…** (**PageAccount**) and **Team…** (**PageTeam**); signed out, nothing changes.
- The second line is "Local · on this Mac" in today's app, because nothing leaves the Mac.
- The avatar is one solid `avatar` fill (#247A43, the same in both themes), with no gradient. Its white initial is 5.33:1.
- Under the pointer the row turns `cardHover`, as a raised control; pressed, `pressed`. It casts no shadow: a HoverCard's `shadow-hover` would lift the sidebar's footer off the window.
