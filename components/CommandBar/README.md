# CommandBar

A single rounded input line with a prompt and a run button, as in a terminal, with options underneath. In Swift:

```swift
CommandBar(placeholder: "Command for \(target.name), for example: df -h", text: $command,
           running: running, onRun: { run() }, onStop: { task?.cancel() }) {
    Toggle("Read-only", isOn: $readOnly)
    Toggle("Dry run", isOn: $dryRun)
}
```

**Provide:** a placeholder with an example, a binding, the running state, a run action, an optional stop action, and options as checkboxes.

- The prompt `chevron.right` is `accent`. The run button is `accent` with text and `text3` when empty. ⌘↩ runs.
- While running, show a small spinner and a ghost **Stop** in place of the run button.
- Each option checkbox has a `.help` that says what it changes ("Show what would run, changing nothing.").
