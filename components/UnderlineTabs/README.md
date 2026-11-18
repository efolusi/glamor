# UnderlineTabs

Tabs drawn as words, with a 2pt `text` rule under the chosen one. In Swift: `UnderlineTabs(items: [(.agent, "SSH Agent"), (.key, "Saved Key"), (.password, "Password")], selection: $auth)`.

**Provide:** two to five short labels and a selection binding. Labels are Title Case like buttons (SSH Agent, Saved Key, SOCKS Proxy) and never start with the lower-case komando: "komando key" became **Saved Key**.

- Use them to switch between ways of entering the same thing (SSH Agent, Saved Key, Password; Local, Remote, SOCKS Proxy) and between the tabs of a target.
- The selected tab is `text` with its rule and the others are `text2`, all in the same `body` weight so a tab never changes width when it is chosen (bold made the row jump); with `space-24` between them; each tab is 28 high including its 2 rule.
