# SearchBar

The search line at the top of a list page: 40 tall, `radius-12`, with an optional action on the right. In Swift: `SearchBar(placeholder: "Find a host, or connect to user@address", text: $query, actionTitle: "Connect", action: connect)`.

**Provide:** a placeholder that says what can be found, a binding, and optionally an action.

- A clear button appears once there is text. The action stays disabled until then, and Return runs it.
- The placeholder names what is searched ("Find a database, cache, bucket, cluster, registry or queue").
