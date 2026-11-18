# TextField

A text input with a `field` fill, a 1pt `border`, `radius-8`, 32 high with 12 at the sides (28 high with 8 when compact). While it has focus, the border turns accent at 70% and 2. In Swift, put a `TextFieldBox` (the `FieldBox` holding a `TextField` or `SecureField`) inside a `FormField`:

```swift
FormField(label: "Local port", help: "Empty: komando picks a free one and shows it here.") {
    TextFieldBox(placeholder: "15432", text: $port, mono: true, label: "Local port")
}
```

**Provide:** a label above in `body-medium`, 8 above the field, an optional help line below in `caption` `text3`, a placeholder, and a binding.

- **One line unless the value is code or a message.** A field is single-line and Return submits the sheet or form: names, addresses, ports, rules, groups, patterns, TTLs, a recipe's blanks, a one-line description, and every password, secret and API key (pasted keys are one long line; a wrapping box made them look like several values). Only three inputs take several lines, grow with their text and use Return for a new line: a recipe's **Command**, the database **Query**, and the agent's **composer**. In the previews, `multiline: true` (with `rows`) draws one; in Swift, `TextEditor` or `TextField(axis: .vertical)`.
- **What Return does.** In a sheet, Return runs the sheet's primary (Save Secret, Start, Save). In a form that fills a tab (New Host, New Connection) and on a recipe's Run, the primary takes ⌘Return, so a Return typed in a long form never saves or runs on servers by accident; its tooltip says so. A search or filter field runs on Return (the cache pattern, ⌘K). In the three multi-line inputs Return adds a line: the composer sends with Return and adds a line with Shift-Return, Command and Query save or run with ⌘Return.
- Use `mono` for anything komando reads literally: addresses, ports, rules, secret names and connection strings.
- Use `secure` for passwords. The help says where the value goes ("Sent to komando through a pipe and stored encrypted. Never shown again.").
- Help is one short sentence with an example ("Comma-separated, for example web, prod.").
