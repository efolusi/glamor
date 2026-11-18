# TargetsField

One "Run on" field for every screen that runs on many servers (M-MV5, owner decision 2026-11-17): Recipes, Start a Job and Put a Key. It holds komando's own target words, so what a person picks here is exactly what komando gets.

**Provide:** the target words, and komando's answer of what they pick.

- **Chips.** Each chip is one of komando's target words (docs/features/targets.md on sgnd/komando): a name (`web-1`), a pattern (`web-*`), a group (`@web`), a tag (`tag:prod`), a label (`label:dc=jkt`), a kind (`kind:db`), an OS (`os:windows`) or `all`. A word that leaves one out (`!web-3`) shows as "not web-3". Each chip is a 24 **k-ctx** with its own remove button; the words are in mono.
- **Add….** A compact ghost button at the right end of the field. Its menu has sections Hosts and Connections, Groups, Tags, Labels and Kinds, then **Leave Out…**, which lists what the words already pick. **Type a Target…** at the end takes any word komando knows.
- **What it sends.** The chips joined with commas, in order, as komando's one target: `@web,tag:prod,!web-3`.
- **The line under it is komando's answer.** The app runs `komando list WORDS -o json` (read only) and shows the count and the names ("3 servers: web-1, web-2, web-4"), with a `lock.fill` count of protected ones and **Show the List**, which opens them as a list. The app never works out the set itself. A word that picks nothing shows komando's own error in place of the line (a target that picks nothing is an error, not an empty result).
- **Both of (later).** An intersection such as `@web&tag:prod` waits for komando (C-MV5). Until komando lists it in `komando schema`, Add… has no "Both of" item.
- **Access.** The field reads "Run on: @web, tag:prod, not web-3"; each chip's remove button names its word. Backspace in the field removes the last chip.
- **Mac only for now.** On iPhone and iPad, **PageiPadRecipes** uses chips of groups and servers with Choose….
