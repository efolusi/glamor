# PanelHeader

The 52 bar at the top of the content panel, with 24 at the sides. It shows the page title in `title-m`, or the open tabs when there is more than one; on the right, the agent (`text.bubble`, ⌘J), refresh, and the page's one create button. In Swift: `PanelHeader()`, which is a window drag area too.

**Provide:** the page's create action, if it has one: **Add** on Hosts and Connections (one name, ⌘N; on Hosts it opens the Server form, **PageNewHost**, and on Connections the chooser, **PageAdd**), New Forward on Port Forwarding, New Recipe on Recipes, New Secret on Keychain. Home has none, the empty Home (**PageWelcome**) and the install page (**PageInstall**) included.

- The create button is the screen's one primary button (32). No other primary sits on the page while it is there.
- The agent and refresh buttons are compact (28) icon-only ghosts with tooltips ("Ask the agent (⌘J)", "Read the inventory again (⌘R)"). Refresh dims to 40% while loading.
- No date and no decoration in the header. The component has no date slot, so none can be added by accident.
- **Rename a tab (gap M17).** A terminal tab's right-click adds **Rename Tab…** above Close Tab: an **AlertDialog** ("Rename Tab", a Name field with the current title, **Rename** and Cancel). The new name shows in the tab and is what a saved workspace keeps; the command it runs does not change.
