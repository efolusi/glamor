# CardList

A card holding rows separated by hairlines inset 16 from the left. Rows are 40 high. With `InfoRow`, it shows the facts about a target. In Swift:

```swift
CardList {
    InfoRow("Kind", "PostgreSQL")
    InfoRow("Address", "db.internal:5432")
    InfoRow("Via", "bastion")
}
```

**Provide:** the rows. An `InfoRow` takes a label (`text2`) and a value (`text`, right-aligned, selectable).

- The dashboard's inventory card uses the same pattern, with 40-high rows and counts in `mono-l`.
- Put a value komando reads literally in mono: addresses, ports, secret references.
