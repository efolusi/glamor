# AgentMessage

One turn of an agent conversation. The person's turns are `subtle` bubbles on the right; the agent's sit on the left beside an `accent` `text.bubble` mark (the agent is a colleague you talk to), with its tool calls and approvals inside the turn.

- The mark is a 28 tile with IconTile's rounded-square corners (`radius-tile`), never a circle. Its centre lines up with the first thing in the turn: a first line of text starts `space-4` down, a ToolCall's 32 head `space-2` up.

**Provide:** the role and the content: paragraphs, **ToolCall**s, an **ApprovalCard**.

- The agent writes like the product: short, specific, names in mono, the next step as a question.
